class @Root extends Polygon
  constructor: (@config = {size: 0}) ->
    super(@config)
    @is_root       = true
    @fixed         = true    
    @size          = 90
    @r.x           = @width / 2
    @r.y           = @height - 180
    @angleStep     = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @bullet_stroke = "none"
    @bullet_fill   = "#000"
    @bullet_size   = 4
    @bullet_speed  = 10 / @dt
    @lastfire      = Utils.timestamp()
    @wait          = 20 # ms between bullets
    @attacker      = [] # no attackers by default
    @charge        = 5e4 
    @stroke("none")
    @fill("#000")
    @bitmap = @g.insert("image", 'path').attr('id', 'ship_image')
    @ship() # morph ship path out of zero-size default path (easy zoom effect)
    d3.timer(@fire)

  update: (xy = d3.mouse(@svg.node())) =>
    return unless @react # don't draw if not active
    @r.x = xy[0]
    @r.y = xy[1]
    @draw()
    @collision_detect()
    if @attacker?
      @update_attacker()

  spin: () =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta
    @rotate_path()
    @draw()

  fire: () =>
    timestamp   = Utils.timestamp()
    return unless @go and timestamp - @lastfire > @wait
    @lastfire   = timestamp
    bullet      = new Bullet()
    bullet.size = @bullet_size
    x           = Math.cos(@angle - Math.PI * 0.5)
    y           = Math.sin(@angle - Math.PI * 0.5)
    bullet.r.x  = @r.x + x * (@size / 3 + bullet.size)
    bullet.r.y  = @r.y + y * (@size / 6)
    bullet.v.x  = @bullet_speed * x  
    bullet.v.y  = @bullet_speed * y
    bullet.stroke(@bullet_stroke)
    bullet.fill(@bullet_fill)
    bullet.n.push(n) for n in @n
    element.n.push(bullet) for element in @n
    bullet.start()
    return

  update_attacker: ->
    return unless @attacker.length > 0
    @params = 
      type: 'charge'
      cx: @r.x
      cy: @r.y
      q:  @charge # charge
    attacker.force.params = @params for attacker in @attacker

  activate: ->
    @react = true
    @start()  
  
  ship: (ship = Ship.sidewinder(), dur = 500) -> # provides a morph effect when switching between ship types using Utils.pathTween
    @path    = ship.path
    @pathBB() # set the rectangular bounding box for this path
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
      .attr("x", -@pathwidth * 0.5 + ship.offset.x).attr("y", -@pathheight * 0.5 + ship.offset.y)
      .attr("width", @pathwidth)
      .attr("height", @pathheight)
      .attr("opacity", 0)
      .transition()
      .delay(dur)
      .duration(dur)
      .attr("opacity", 1)
      .each('end', () => @set_path())
      
  start: ->
    super
    @svg.on("mousemove", @update) # default mouse behavior is to control the root element position
    @svg.on("mousedown", @fire)   # default mouse button listener
    @svg.on("mousewheel", @spin)  # default scroll wheel listener
  
    
  stop: ->
    super
    @svg.on("mousemove", null)  # default mouse behavior is to control the root element position
    @svg.on("mousedown", null)  # default mouse button listener
    @svg.on("mousewheel", null) # default scroll wheel listener

  death_check: (n) ->
    n.death()
    @death()
    Gamescore.lives -= 1 # decrement lives for this game
    true # return true to prevent default reaction from triggering
    
  death: -> # drone death effect to run when we kill a drone
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
    @bitmap.transition().duration(dur).attr('opacity', 0)  