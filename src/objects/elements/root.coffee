class @Root extends Polygon
  constructor: (@config = {}) ->
    super
    @is_root   = true
    @fixed     = true    
    @size      = 90
    @x         = @width / 2
    @y         = @height - @size * 2
    @angleStep = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @stroke("#700")
    @fill("#none")
    @path = @config.path || Ship.sidewinder # default ship type
    @ship()
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)
    @attacker = [] # no attackers by default
    @charge = 5e4 
    d3.timer(@fire)
    @bullet_stroke = "none"
    @bullet_fill   = "#000"
    @bullet_size   = 4
    @bullet_speed  = 10 / @dt
    # @draw()

  update: (xy = d3.mouse(@svg.node())) =>
    return unless @react # don't draw if not active
    @x = xy[0]
    @y = xy[1]
    @draw()
    @collision_detect()
    if @attacker?
      @update_attacker()

  spin: () =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta
    @draw()

  fire: () =>
    dt = 6
    return unless @go and Utils.timestamp() % dt < dt * 0.4
    bullet      = new Bullet()
    bullet.stroke(@bullet_stroke)
    bullet.fill(@bullet_fill)
    bullet.size = @bullet_size
    x           = Math.cos(@angle - Math.PI * 0.5)
    y           = Math.sin(@angle - Math.PI * 0.5)
    bullet.x    = @x + x * (@size / 3 + bullet.size)
    bullet.y    = @y + y * (@size / 6)
    bullet.u    = @bullet_speed * x  
    bullet.v    = @bullet_speed * y
    bullet.n.push(n) for n in @n
    element.n.push(bullet) for element in @n
    bullet.start()
    return

  update_attacker: ->
    return unless @attacker.length > 0
    @params = 
      type: 'charge'
      cx: @x
      cy: @y
      q:  @charge # charge
    attacker.force.params = @params for attacker in @attacker

  activate: ->
    @react = true
    @start()  
  
  ship: (ship = @path, dur = 500) ->
    @path = ship 
    endPath = @d() # new end-path to morph to
    @image.data([endPath]).transition().duration(dur).attrTween("d", Utils.pathTween)

  start: ->
    super
    @svg.on("mousemove", @update) # default mouse behavior is to control the root element position
    @svg.on("mousedown", @fire) # default mouse button listener
    @svg.on("mousewheel", @spin) # default scroll wheel listener
  
    
  stop: ->
    super
    @svg.on("mousemove", null) # default mouse behavior is to control the root element position
    @svg.on("mousedown", null) # default mouse button listener
    @svg.on("mousewheel", null) # default scroll wheel listener

  death: ->
    N    = 240 # random color parameter
    fill = '#ff0' # "hsl(" + Math.random() * N + ", 80%," + "40%" + ")" # fill     = "hsl(" + Math.random() * N + ", 80%," + 0.5 * Math.sqrt(circle.u * circle.u + circle.v * circle.v) + ")"
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
    console.log(fill)
    Gamescore.lives -= 1 # decrement lives for this game
