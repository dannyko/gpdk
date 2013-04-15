class @Root extends Polygon
  constructor: (@config = {}) ->
    super
    @is_root   = true
    @fixed     = true    
    @size      = 90
    @r.x       = @width / 2
    @r.y       = @height - @size * 2
    @angleStep = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @stroke("#700")
    @fill("#none")
    @ship()
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)
    @attacker = [] # no attackers by default
    @charge   = 5e4 
    d3.timer(@fire)
    @bullet_stroke = "none"
    @bullet_fill   = "#000"
    @bullet_size   = 4
    @bullet_speed  = 10 / @dt
    @lastfire      = Utils.timestamp()
    @wait          = 20 # ms between bullets

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
  
  ship: (ship = Ship.sidewinder, dur = 500) ->
    @path = ship.path
    endPath = @d() # new end-path to morph to
    @image.data([endPath])
      .transition()
      .duration(dur)
      .attrTween("d", Utils.pathTween)
      .each('end', () => @set_path(ship.path))

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
  
  death: ->
    N    = 240 # random color parameter
    fill = '#ff0' 
    dur  = 120 # color effect transition duration parameter
    @image # default reaction
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("fill", @fill())
  