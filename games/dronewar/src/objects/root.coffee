class @Root extends Polygon
  constructor: (@config = {size: 0}) ->
    super(@config)
    @is_root       = true
    @init()

  init: ->
    @r.x           = Game.width / 2
    @r.y           = Game.height - 180
    @angle         = 0
    @angleStep     = 2 * Math.PI / 40 # initialize per-step angle change magnitude 
    @lastfire      = undefined # initialize timestamp
    @charge        = 2e4 # sets drone interaction strength
    @stroke("none")
    @fill("#000")
    @bitmap  = @g.insert("image", 'path').attr('id', 'ship_image')
    @ship() # morph ship path out of zero-size default path (easy zoom effect)
    @tick    = -> return
    @drawing = false
    @fadeIn()
    @

  redraw: (xy = d3.mouse(@game_g.node())) =>
    return unless @collision # don't draw if not active
    maxJump = 70 # max jump size
    xy      = @apply_limits(xy)
    if Math.abs(@r.x - xy[0]) > maxJump or Math.abs(@r.y - xy[1]) > maxJump
      @redraw_interp(xy)
      return
    @r.x = xy[0]
    @r.y = xy[1]
    return

  apply_limits: (xy) ->
    [Math.min(Math.max(@bb_width, xy[0]), Game.width - @bb_width), Math.min(Math.max(@bb_height, xy[1]), Game.height - @bb_height)]

  redraw_interp: (xy = d3.mouse(@game_g.node())) =>
    return unless @collision # don't draw if not active
    return if @drawing
    @drawing = true
    @dr.init({x: xy[0], y: xy[1]})
    step = 20 # steplength
    @dr.subtract(@r)
    Nstep = Math.floor(@dr.length() / step)
    count = 1
    @dr.normalize(step) # difference vector pointing towards destination
    redraw_func = =>
      if count > Nstep
        @drawing = false
        return true
      else 
        @r.add(@dr) if @r.x > 0 and @r.x < Game.width and @r.y > 0 and @r.y < Game.height
        count++
        return false
    Physics.callbacks.push(redraw_func)
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
    delta = if Math.abs(deltay) > Math.abs(deltax) then deltay else deltax
    @angle = @angle - delta
    @rotate_path()
    return

  fire: =>
    return true if @is_removed
    return if Gamescore.lives < 0 # do nothing if game is over / ending
    if @lastfire is undefined
      @lastfire = Physics.timestamp
      return
    return unless (Physics.timestamp - @lastfire) >= @wait
    @lastfire = Physics.timestamp
    @shoot()
    return
  
  bullet_config = {power: null, size: null} 

  shoot: ->
    x = Math.cos(@angle - Math.PI * 0.5)
    y = Math.sin(@angle - Math.PI * 0.5)
    bullet_config.power = @bullet_size * @bullet_size
    bullet_config.size  = @bullet_size
    bullet = Factory.spawn(Bullet, bullet_config) # spawn replaces object creation; i.e., new Bullet({power: @bullet_size * @bullet_size})
    bullet.r.x = @r.x + x * (@size / 3 + @bullet_size)
    bullet.r.y = @r.y + y * 20
    bullet.v.x = @bullet_speed * x
    bullet.v.y = @bullet_speed * y
    bullet.stroke(@bullet_stroke)
    bullet.fill(@bullet_fill)
    bullet.start()
    return

  ship: (ship = Ship.sidewinder(), dur = 500) -> # provides a morph effect when switching between ship types using Utils.pathTween
    @collision = false
    @bullet_stroke = ship.bullet_stroke
    @bullet_fill   = ship.bullet_fill
    @bullet_size   = ship.bullet_size
    @bullet_speed  = ship.bullet_speed / @dt
    @wait          = ship.bullet_tick # ms between bullets
    @path          = ship.path
    @BB() # set the rectangular bounding box for this path
    endPath  = @d_attr() # new end-path to morph to
    @bitmap.attr('opacity', 1)
      .transition()
      .duration(dur * 0.5)
      .attr('opacity', 0)
      .remove()
    @image.attr("opacity", 1)
      .data([endPath])
      .transition()
      .duration(dur)
      .attrTween("d", Utils.pathTween)
      .transition()
      .duration(dur * 0.5)
      .attr("opacity", 0)
    @bitmap.attr("xlink:href", ship.url)
      .attr("x", -@bb_width * 0.5 + ship.offset.x).attr("y", -@bb_height * 0.5 + ship.offset.y)
      .attr("width", @bb_width)
      .attr("height", @bb_height)
      .attr("opacity", 0)
      .transition()
      .delay(dur)
      .duration(dur)
      .attr("opacity", 1)
      .each('end', => 
        @set_path()
        @collision = true
        Physics.callbacks.push(@fire)
      )
      
  start: ->
    super
    @svg.on("mousemove", @redraw) # default mouse behavior is to control the root element position
    @svg.on("mousewheel", @spin)  # default scroll wheel listener
    @svg.call(d3.behavior.drag().origin(Object).on("drag", @dragspin))
    
  stop: ->
    super
    @svg.on("mousemove", null)  # default mouse behavior is to control the root element position
    @svg.on("mousewheel", null) # default scroll wheel listener
    @svg.call(d3.behavior.drag().origin(Object).on("drag", null))
    
  reaction: (n) -> # what happens when root gets hit by a drone
    return if n.is_bullet # bullets don't hurt the ship
    damage = 10
    Gamescore.lives -= damage # decrement lives for this game
    if Gamescore.lives < 0
      Game.instance.stop()
    else
      Game.instance.text()
    n.remove()
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
    @bitmap.transition()
      .duration(2 * dur)
      .ease('linear')
      .attr('transform', 'scale(10)')
      .attr('opacity', 0)
    @g.transition()
      .duration(dur)
      .ease('linear')
      .style('opacity', 0)
