class @Root extends Circle
  constructor: (@config = {}) ->
    super
    @is_root   = true
    @physics     = true    
    @image.attr("fill", "#FFF")
    @size      = 13
    @angle     = -Math.PI * 0.5 # initialize bullet angle
    @angleStep = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @svg.on("mousemove", @draw) # default mouse behavior is to control the root element position
    d3.select(window).on("keydown", @keydown) # default keyboard listener
    @svg.on("mousedown", @fire) # default mouse button listener
    @svg.on("mousewheel", @spin) # default scroll wheel listener

  draw: (node = @svg.node()) =>
    xy = d3.mouse(node)
    @r.x = xy[0]
    @r.y = xy[1]
    super()

  spin: () =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta

  keydown: () =>
    switch d3.event.keyCode 
      when 70 then @fire() # f key fires bullets
      when 39 then @angle += @angleStep # right arrow changes firing angle by default
      when 37 then @angle -= @angleStep # left arrow changes firing angle by default
      when 38 then @fire() # up arrow fires bullet
      when 40 then @angle += Math.PI # down arrow reverses direction of firing angle 
    return

  fire: () =>
    bullet      = new Bullet()
    speed       = 5.5 / @dt
    x           = Math.cos(@angle)
    y           = Math.sin(@angle)
    bullet.r.x    = @r.x + x * (@size / 3 + bullet.size)
    bullet.r.y    = @r.y + y * (@size / 3 + bullet.size)
    bullet.v.x    = speed * x
    bullet.v.y    = speed * y
    bullet.start()
  
  destroy_check: (n) ->
    d = new Vec(n.r).subtract(@r).normalize()
    bump = 0.1 / @dt
    n.v.add(d.scale(bump))
    true