class @Element
  constructor: (@config = {}) ->      
    @dt        = @config.dt      || 0.4 # controls animation smoothness relative to d3.timer queue update rate
    @svg       = @config.svg     || d3.select("#game_svg")
    @width     = @svg.attr("width")
    @height    = @svg.attr("height")
    @r         = @config.r       || new Vec() # position vector (rx, ry)
    @v         = @config.v       || new Vec() # velocity vector (vx, vy)
    @f         = @config.f       || new Vec() # force    vector (fx, fy)
    @n         = @config.n       || [] # array of references to neighbor elements that this element interacts with
    @force     = @config.force   || new Force() # object for computing force vectors: force.f() = [fx, fy]
    @size      = @config.size    || 0 # zero default size in units of pixels for abstract class
    @g         = @config.g       || d3.select("#game_g").append("g").attr("transform", "translate(" + @x + "," + @y + ")")
    @image     = @config.image   || null # no image by default for generic element: user must specify
    @go        = @config.go      || false # timer is not immediately on by default
    @react     = @config.true    || true # boolean switching the element readiness for reactions to collisions
    @tol       = @config.tol     || 0.1 # default tolerance for collision resolution i.e. padding when updating positions to resolve conflicts
    @fixed     = @config.fixed   || false # can it move without external control or not
    @_stroke   = @config.stroke  || "none" # use underscore to avoid namespace collision with getter/setter method @stroke()
    @_fill     = @config.fill    || "black" # use underscore to avoid namespace collision with getter/setter method @fill()
    @angle     = @config.angle   || 0 # angle for rigid body rotation
    @is_root   = @config.is_root || false # default boolean for root element control
    @is_bullet = @config.is_bullet || false # default boolean for bullet effects
    @type      = @config.type    || null # default type is null for abstract class
    Utils.addChainedAttributeAccessor(@, 'fill')
    Utils.addChainedAttributeAccessor(@, 'stroke')
        
  collision_detect: -> # default collision detection
    return unless @react
    for n in @n
      continue unless n.react
      Collision.check(@, n)
      
  integrate: () =>
    # simulate Newtonian dynamics using approximate velocity Verlet algorithm: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
    return if @fixed
    r    = new Vec(@r) # clone the current position vector object for later comparison
    f    = @force.f(r)
    @r.x = @r.x + @v.x * @dt + 0.5 * f.x * @dt * @dt # update position
    @r.y = @r.y + @v.y * @dt + 0.5 * f.y * @dt * @dt # update position
    @f   = @force.f(@r)
    @v.x = @v.x + 0.5 * (@f.x + f.x) * @dt # Verlet velocity draw, assuming that the force is velocity-independent
    @v.y = @v.y + 0.5 * (@f.y + f.y) * @dt # Verlet velocity draw, assuming that the force is velocity-independent
    if r.x isnt @r.x or r.y isnt @r.y
      @draw()
      @collision_detect() # check for collisions if position changes
    if @go
      return
    else
      true      

  draw: ->
    @g.attr("transform", "translate(" + @r.x + "," + @r.y + ") rotate(" + (360 * 0.5 * @angle / Math.PI) + ")")
    return
    
  start: (delay = null) ->
    @go = true
    return if @fixed
    d3.timer(@integrate, delay)
    return
    
  stop: ->
    @go = false
    return  
    
  deactivate: ->
    @react = false
    @fixed = true
    @stop()  
    return
    
  activate: ->
    @react = true
    @fixed = false
    @start()  
    return

  death_check: (n) ->
    check = @is_root || @is_bullet || n.is_root || n.is_bullet # check if root or bullet
    if check
      m.death()
      n.death()
    check

  death: -> 
    @deactivate()
    @g.remove() # avoids accumulating indefinite numbers of dead elements
    return