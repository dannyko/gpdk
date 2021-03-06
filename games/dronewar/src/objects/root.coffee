class $z.Root extends $z.Polygon
  constructor: (@config = {size: 0}) ->
    super(@config)
    @is_root       = true
    @init()

  init: ->
    @r.x           = $z.Game.width / 2
    @r.y           = $z.Game.height - 180
    @angle         = 0
    @angleStep     = 2 * Math.PI / 40 # initialize per-step angle change magnitude 
    @lastfire      = undefined # initialize timestamp
    @charge        = 3 # sets drone interaction strength
    @stroke("none")
    @fill("#000")
    @shipImage     = @g.insert("image", 'path').attr('id', 'ship_image')
    @ship() # morph ship path out of zero-size default path (easy zoom effect)
    @tick          = -> return
    @drawing       = false
    @

  redraw: (xy = d3.mouse(@game_g.node())) =>
    return if $z.Physics.off
    return unless @collision # don't draw if not active
    # return if (d3.event.defaultPrevented) # click suppressed
    # maxJump = 70 # max jump size
    # console.log('before', xy[0], xy[1])
    xy      = @apply_limits(xy)
    # console.log('after', xy[0], xy[1])
    #if Math.abs(@r.x - xy[0]) > maxJump or Math.abs(@r.y - xy[1]) > maxJump
    @interrupt = true # in case we're still in the middle of a movement loop
    @redraw_interp(xy)
    return

  apply_limits: (xy) ->
    [Math.min(Math.max(@bb_width, xy[0]), $z.Game.width - @bb_width), Math.min(Math.max(@bb_height, xy[1]), $z.Game.height - @bb_height)]

  redraw_interp: (xy = d3.mouse(@game_g.node())) =>
    return unless @collision # don't draw if not active
    # return if @drawing
    step = 20 # steplength
    count = 1
    redraw_func = =>
      @dr.init({x: xy[0], y: xy[1]})
      @dr.subtract(@r)
      if @dr.length() < step or (count > 1 and @interrupt)
        # console.log('final', @r)
        return true
      else 
        @interrupt = false if count is 1
        count++
        @dr.normalize(step) # difference vector pointing towards destination
        # console.log(xy[0], xy[1], @r.x, @r.y, @dr.x, @dr.y)
        @r.add(@dr) # if @r.x > @bb_width and @r.x < ($z.Game.width - @bb_width) and @r.y > @bb_height and @r.y < ($z.Game.height - @bb_height)
        return false
    d3.timer(redraw_func)
    return
 
  spin: =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta
    @rotate_path()
    return

  dragspin: =>
    deltay = @angleStep * Math.ceil(d3.event.dy) / Math.abs(Math.ceil(d3.event.dy))
    deltay = 0 if isNaN(deltay)
    deltax = @angleStep * Math.ceil(d3.event.dx) / Math.abs(Math.ceil(d3.event.dx))
    deltax = 0 if isNaN(deltax)
    delta  = if Math.abs(deltay) > Math.abs(deltax) then deltay else deltax
    @angle = @angle - delta
    @rotate_path()
    return

  fire: =>
    return true if @is_removed
    return if $z.Gamescore.lives < 0 # do nothing if game is over / ending
    if @lastfire is undefined or @lastfire > $z.Physics.timestamp
      @lastfire = $z.Physics.timestamp
      return
    return unless ($z.Physics.timestamp - @lastfire) >= @wait
    @lastfire = $z.Physics.timestamp
    @shoot()
    return
  
  bullet_config = {power: null, size: null} 

  shoot: ->
    x = Math.cos(@angle - Math.PI * 0.5)
    y = Math.sin(@angle - Math.PI * 0.5)
    bullet_config.power = @bullet_size * @bullet_size
    bullet_config.size  = @bullet_size
    bullet = $z.Factory.spawn($z.Bullet, bullet_config) # spawn replaces object creation; i.e., new Bullet({power: @bullet_size * @bullet_size})
    bullet.r.x = @r.x + x * (@size / 3 + @bullet_size)
    bullet.r.y = @r.y + y * 20
    bullet.v.x = @bullet_speed * x * .025
    bullet.v.y = @bullet_speed * y * .025
    bullet.stroke(@bullet_stroke)
    bullet.fill(@bullet_fill)
    # console.log('root.shoot', x, y, bullet.r.x, bullet.r.y, bullet.v.x, bullet.v.y)
    bullet.start()
    return

  ship: (ship = $z.Ship.cobra(), dur = 1000) -> # provides a morph effect when switching between ship types using $z.Utils.pathTween
    @collision = false
    $z.Physics.callbacks = []
    @bullet_stroke = ship.bullet_stroke
    @bullet_fill   = ship.bullet_fill
    @bullet_size   = ship.bullet_size
    @bullet_speed  = ship.bullet_speed / @dt
    @wait          = ship.bullet_tick # ms between bullets
    @path          = ship.path
    @BB() # set the rectangular bounding box for this path
    endPath  = @d_attr() # new end-path to morph to
    @image.attr("opacity", .2)
      .attr('fill', '#FFF')
      .data([endPath])
      .transition()
      .duration(dur * 0.25)
      .ease('linear')
      .attrTween("d", $z.Utils.pathTween)
      .transition()
      .duration(dur * 0.5)
      .ease('linear')
      .attr("opacity", 0)
    @g
      .transition()
      .ease('linear')
      .duration(dur * 0.5)
      .style('opacity', 0)
      .each('end', =>
        @shipImage
          .attr("xlink:href", ship.url)    
          .attr("x", -@bb_width * 0.5 + ship.offset.x)
          .attr("y", -@bb_height * 0.5 + ship.offset.y)
          .attr("width", @bb_width)
          .attr("height", @bb_height)
        # @set_path()
        @g
          .transition()
          .delay(dur * 0.125)
          .duration(dur)
          .ease('linear')
          .style('opacity', 1)
          .each('end', =>
            @collision = true
            $z.Physics.callbacks[0] = @fire
          )
      )

  start: ->
    super
    # d3.select(document.body).on("mousemove", @redraw) # default mouse behavior is to control the root element position
    d3.select(document.body).on("mousewheel", @spin)  # default scroll wheel listener
    d3.select(document.body).call(d3.behavior.drag().origin(Object).on("dragstart", @redraw).on("drag", @dragspin))
    
  stop: ->
    super
    # d3.select(document.body).on("mousemove", null)  # default mouse behavior is to control the root element position
    d3.select(document.body).on("mousewheel", null) # default scroll wheel listener
    d3.select(document.body).call(d3.behavior.drag().origin(Object).on("dragstart", null).on("drag", null))
    
  reaction: (n) -> # what happens when root gets hit by a drone
    if n.is_bullet # bullets don't hurt the ship
      n.remove()
      return
    return if $z.Gamescore.lives < 0 # game is already over or ending
    damage = 10
    $z.Gamescore.lives -= damage # decrement lives for this game
    if $z.Gamescore.lives < 0
      @charge = 0 # drones stop attacking root when it's destroyed
      $z.Game.instance.stop()
    else
      $z.Game.instance.text()
    n.remove() unless $z.Gamescore.lives < 0 # don't remove the drone that kills the root element
    N    = 240 # random color parameter
    fill = '#ff0' 
    dur  = 150 # color effect transition duration parameter
    @image # default reaction
      .transition()
      .duration(dur / 5)
      .attr('opacity', 1)
      .ease('linear')
      .transition()
      .duration(dur)
      .ease('poly(0.5)')
      .attr("fill", fill)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("fill", @fill())
      .transition()
      .duration(dur)
      .ease('linear')
      .attr('opacity', 0)
      
  remove: (dur = 500) ->
    @collision = false
    @image.transition()
      .duration(dur * 0.5)
      .attr('opacity', 1)
      .transition()
      .duration(1.5 * dur)
      .attr("fill", "#900")
      .transition()
      .duration(dur * 0.25 )
      .ease('linear')
      .style("opacity", 0)
    @shipImage.transition()
      .duration(2 * dur)
      .ease('linear')
      .attr('transform', 'scale(10)')
      .attr('opacity', 0)
    @g.transition()
      .duration(dur)
      .ease('linear')
      .style('opacity', 0)
