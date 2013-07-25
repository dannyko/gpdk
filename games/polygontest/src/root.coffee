class @Root extends Polygon
  constructor: (@config = {}) ->
    super
    @is_root   = true
    @size      = 13
    @path      = @default_path()
    @angle     = 0 # Math.PI 
    @angleStep = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @fill("#FFF")
    @svg.on("mousemove", @move) # default mouse behavior is to control the root element position
    d3.select(window).on("keydown", @keydown) # default keyboard listener
    @svg.on("mousedown", @fire) # default mouse button listener
    @svg.on("mousewheel", @spin) # default scroll wheel listener
    @set_path()
    
  move: (node = @svg.node()) =>
    xy = d3.mouse(node)
    @r.x = xy[0]
    @r.y = xy[1]
    @draw()
    
  spin: () =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta
    @rotate_path()
    @draw()
    
  keydown: () =>
    switch d3.event.keyCode 
      when 70 then @fire() # f key fires bullets
      when 39 then @angle += @angleStep # right arrow changes firing angle by default
      when 37 then @angle -= @angleStep # left arrow changes firing angle by default
      when 38 then @fire() # up arrow fires bullet
      when 40 then @angle += Math.PI # down arrow reverses direction of firing angle 
    return
    
  fire: () =>
    bullet     = new Bullet()
    speed      = 5.5 / @dt
    x          = Math.cos(@angle - Math.PI * 0.5)
    y          = Math.sin(@angle - Math.PI * 0.5)
    bullet.r.x = @r.x + x * (@size / 3 + bullet.size)
    bullet.r.y = @r.y + y * (@size / 3 + bullet.size)
    bullet.v.x = speed * x
    bullet.v.y = speed * y
  
  destroy_check: (n) ->
    bump = 0.1 / @dt
    d = new Vec(n.r).subtract(@r).normalize().scale(bump)
    n.v.add(d)