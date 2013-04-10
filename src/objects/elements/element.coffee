class @Element
  constructor: (@config = {}) ->      
    @dt        = @config.dt      || 0.4 # controls animation smoothness relative to d3.timer queue update rate
    @svg       = @config.svg     || d3.select("#game_svg")
    @width     = @svg.attr("width")
    @height    = @svg.attr("height")
    @x         = @config.x       || 0 
    @y         = @config.x       || 0 
    @u         = @config.v       || 0 
    @v         = @config.v       || 0 
    @f         = @config.f       || [0, 0] # current force vector [fx, fy]
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
    @game      = @config.game    || null # default reference to parent game object containing the element instance
    Utils.addChainedAttributeAccessor(@, 'fill')
    Utils.addChainedAttributeAccessor(@, 'stroke')
    
    
  distance: -> # Euclidean distance to all other Element "g" tag containers 
    d = [] # initialize
    for element in @n # loop over neighboring elements
      continue if not element?
      a    = @x - element.x # horizontal displacement
      b    = @y - element.y # vertical displacement
      dist = Math.sqrt(a * a + b * b) # Euclidean distance i.e. Pythagorean theorem
      d.push(dist) # add neighbor distance to output array
    d # return d
    
    
  collision_detect: -> # default collision detection
    return unless @react
    for n in @n
      continue unless n.react
      Collision.check(@, n)
      
  integrate: () =>
    # simulate Newtonian dynamics using approximate velocity Verlet algorithm: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
    return if @fixed
    x  = @x
    y  = @y
    f  = @force.f(x, y)
    @x = @x + @u * @dt + 0.5 * f[0] * @dt * @dt # update position
    @y = @y + @v * @dt + 0.5 * f[1] * @dt * @dt # update position
    @f = @force.f(@x, @y)
    @u = @u + 0.5 * (@f[0] + f[0]) * @dt # Verlet velocity draw, assuming that the force is velocity-independent
    @v = @v + 0.5 * (@f[1] + f[1]) * @dt # Verlet velocity draw, assuming that the force is velocity-independent
    if x isnt @x or y isnt @y
      @draw()
      @collision_detect() # check for collisions if position changes
    if @go
      return
    else
      true      

  draw: ->
    @g.attr("transform", "translate(" + @x + "," + @y + ")rotate(" + (360 * 0.5 * @angle / Math.PI) + ")")
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
    
  activate: ->
    @react = true
    @fixed = false
    @start()  

  death: -> 
    @deactivate()
    @g.remove() # avoids accumulating indefinite numbers of dead elements