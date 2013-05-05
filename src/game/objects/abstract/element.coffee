class @Element
  constructor: (@config = {}) ->      
    @dt        = @config.dt        || 0.4 # controls animation smoothness relative to d3.timer queue update rate
    @r         = @config.r         || new Vec() # position vector (rx, ry)
    @v         = @config.v         || new Vec() # velocity vector (vx, vy)
    @f         = @config.f         || new Vec() # force    vector (fx, fy)
    @n         = @config.n         || [] # array of references to neighbor elements that this element interacts with
    @force     = @config.force     || new Force() # object for computing force vectors: force.f() = [fx, fy]
    @size      = @config.size      || 0 # zero default size in units of pixels for abstract class
    @go        = @config.go        || false # timer is not immediately on by default
    @react     = @config.true      || true # boolean switching the element readiness for reactions to collisions
    @tol       = @config.tol       || 0.5 # default tolerance for collision resolution i.e. padding when updating positions to resolve conflicts
    @fixed     = @config.fixed     || false # can it move without external control or not
    @_stroke   = @config.stroke    || "none" # use underscore to avoid namespace collision with getter/setter method @stroke()
    @_fill     = @config.fill      || "black" # use underscore to avoid namespace collision with getter/setter method @fill()
    @angle     = @config.angle     || 0 # angle for rigid body rotation
    @is_root   = @config.is_root   || false # default boolean for root element control
    @is_bullet = @config.is_bullet || false # default boolean for bullet effects
    @type      = @config.type      || null # default type is null for abstract class
    @image     = @config.image     || null # no image by default for generic element: user must specify
    @g         = d3.select("#game_g")
                  .append("g")
                  .attr("transform", "translate(" + @r.x + "," + @r.y + ")")
    @g         = @config.g         || @g
    @svg       = @config.svg       || d3.select("#game_svg")
    @quadtree  = @config.quadtree  || null
    @width     = @svg.attr("width")
    @height    = @svg.attr("height")
    @tick      = 10 # minimum time between ticks
    @lasttick  = Utils.timestamp()
    Utils.addChainedAttributeAccessor(@, 'fill')
    Utils.addChainedAttributeAccessor(@, 'stroke')
        
  collision_detect: -> # default collision detection
    return unless @react and Collision.list.length > 0
    Collision.update_quadtree()
    size = Math.max(2 * @size + @tol, 50)
    x0 = @r.x - size
    x3 = @r.x + size
    y0 = @r.y - size
    y3 = @r.y + size
    Collision.quadtree.visit( (node, x1, y1, x2, y2) =>
      p = node.point 
      if p isnt null
        return false unless this isnt p.d and p.d.react # skip this point and continue searching lower levels of the hierarchy
        if (p.x >= x0) and (p.x < x3) and (p.y >= y0) and (p.y < y3)
          # console.log(@, p.d)
          Collision.check(@, p.d)
      x1 >= x3 || y1 >= y3 || x2 < x0 || y2 < y0
    )
#    else # old neighbor detection - exhaustive (slow)
 #     for n in @n
  #      continue unless n.react
   #     Collision.check(@, n)

  reaction: (n = undefined) -> # abstract reaction with neighbor n
    n.reaction() if n?
          
  integrate: () => # default update assumes force is independent of velocity i.e. f(x, v) = f(x)
    # simulate Newtonian dynamics using approximate velocity Verlet algorithm: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
    timestamp = Utils.timestamp()
    return if @fixed or timestamp - @lasttick <= @tick
    r = new Vec(@r) # clone the current position vector object for later comparison
    f = @force.f(r) # evaluate the force at the current position
    @r.add(new Vec(@v).scale(@dt)).add(new Vec(f).scale(0.5 * @dt * @dt)) # update position
    @f = @force.f(@r) # evaluate and store force value with respect to the updated position
    @v.add(f.add(@f).scale(0.5 * @dt)) # Verlet velocity update, assuming that the force is velocity-independent
    @lasttick = timestamp
    if r.x isnt @r.x or r.y isnt @r.y # check for position change
      @draw() # force draw before checking for collision
      @collision_detect() # check for collisions if position changes
    if @go
      return
    else # stop the d3.timer by returning true
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
    if @is_root # check if root
      return n.death_check(@) # call root death check
    if @is_bullet # check if bullet after root in order of precedence
      return n.death_check(@) # call bullet death check
    false

  death: -> 
    @deactivate()
    @g.remove() # avoids accumulating indefinite numbers of dead elements
    return