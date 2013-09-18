class @Root extends Polygon
  constructor: (@config = {size: 0}) ->
    super(@config)
    @is_root       = true
    @r.x           = Game.width / 2
    @r.y           = Game.height - 180
    @angleStep     = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @lastfire      = Utils.timestamp()
    @charge        = 5e4
    @stroke("none")
    @fill("#000")
    @bitmap = @g.insert("image", 'path').attr('id', 'ship_image')
    @ship() # morph ship path out of zero-size default path (easy zoom effect)
    @tick = -> return

  redraw: (xy = d3.mouse(@svg.node())) =>
    return unless @collision # don't draw if not active
    @r.x = xy[0]
    @r.y = xy[1]
    @draw()

  spin: () =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta
    @rotate_path()
    @draw()

  fire: () =>
    timestamp   = Utils.timestamp()
    return true if @is_destroyed
    return unless @collision and timestamp - @lastfire >= @wait
    @lastfire   = timestamp
    bullet      = new Bullet()
    bullet.size = @bullet_size
    x           = Math.cos(@angle - Math.PI * 0.5)
    y           = Math.sin(@angle - Math.PI * 0.5)
    bullet.r.x  = @r.x + x * (@size / 3 + bullet.size)
    bullet.r.y  = @r.y + y * 20
    bullet.v.x  = @bullet_speed * x  
    bullet.v.y  = @bullet_speed * y
    bullet.stroke(@bullet_stroke)
    bullet.fill(@bullet_fill)
    bullet.draw()
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
    endPath  = @d() # new end-path to morph to
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
      .each('end', () => @set_path() ; @collision = true ; d3.timer(@fire))
      
  start: ->
    super
    @svg.on("mousemove", @redraw) # default mouse behavior is to control the root element position
    @svg.on("mousedown", @fire)   # default mouse button listener
    @svg.on("mousewheel", @spin)  # default scroll wheel listener
  
    
  stop: ->
    super
    @svg.on("mousemove", null)  # default mouse behavior is to control the root element position
    @svg.on("mousedown", null)  # default mouse button listener
    @svg.on("mousewheel", null) # default scroll wheel listener
    
  reaction: (n) -> # what happens when root gets hit by a drone
    return if n.is_bullet # bullets don't hurt the ship
    Game.lives -= 1 # decrement lives for this game
    n.destroy()
    N    = 240 # random color parameter
    fill = '#ff0' 
    dur  = 120 # color effect transition duration parameter
    @image # default reaction
      .transition()
      .duration(dur / 5)
      .attr('opacity', 1)
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("fill", @fill())
      .transition()
      .duration(dur / 5)
      .attr('opacity', 0)
      
  game_over: (dur = 500) ->
    @image.transition()
      .duration(dur / 5)
      .attr('opacity', 1)
      .transition()
      .duration(dur)
      .attr("fill", "#900")
      .transition()
      .duration(dur * 0.25 )
      .ease('sqrt')
      .style("opacity", 0)
    @bitmap.transition().duration(dur).attr('opacity', 0).each('end', => @destroy())