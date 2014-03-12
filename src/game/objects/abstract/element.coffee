class @Element
  constructor: (@config = {}) ->      
    @dt           = @config.dt          || 0.4 # controls displacement of Physics engine relative to the framerate
    @r            = @config.r           || Factory.spawn(Vec) # position vector (rx, ry)
    @dr           = @config.dr          || Factory.spawn(Vec) # displacement vector (dx, dy)
    @v            = @config.v           || Factory.spawn(Vec) # velocity vector (vx, vy)
    @f            = @config.f           || Factory.spawn(Vec) # force vector (fx, fy)
    @fcopy        = @config.f           || Factory.spawn(Vec) # copy of force vector (fx, fy) to speed up physics computations
    @d            = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @ri           = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @rj           = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @r_temp       = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @dr_temp      = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @line         = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @normal       = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @lshift       = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @vPar         = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @vPerp        = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @uPar         = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @uPerp        = Factory.spawn(Vec) # temporary vector used by the Physics engine
    @force_param  = @config.force_param || [] # array of objects for computing net force vectors 
    @size         = @config.size        || 0 # zero default size in units of pixels for abstract class
    @bb_width     = @config.bb_width    || 0 # bounding box width
    @bb_height    = @config.bb_height   || 0 # bounding box height
    @left         = @config.bb_width    || 0 # bounding box left
    @right        = @config.bb_height   || 0 # bounding box right
    @top          = @config.top         || 0 # bounding box top
    @bottom       = @config.bottom      || 0 # bounding box bottom
    @collision    = @config.collision   || true # element is created and exists in memory but is not part of the game (i.e. staged to enter or exit)
    @tol          = @config.tol         || 0.25 # default tolerance for collision resolution i.e. padding when updating positions to resolve conflicts
    @_stroke      = @config.stroke      || "none" # use underscore to avoid namespace collision with getter/setter method @stroke()
    @_fill        = @config.fill        || "black" # use underscore to avoid namespace collision with getter/setter method @fill()
    @angle        = @config.angle       || 0 # angle for rigid body rotation
    @is_root      = @config.is_root     || false # default boolean for root element control
    @is_bullet    = @config.is_bullet   || false # default boolean for bullet effects
    @type         = @config.type        || null # default type is null for abstract class
    @image        = @config.image       || null # no image by default for generic element: user must specify
    @g            = d3.select("#game_g")
                    .append("g")
                    .attr("transform", "translate(" + @r.x + "," + @r.y + ")")
                    .style('opacity', 0)
    @g            = @config.g           || @g
    @svg          = @config.svg         || d3.select("#game_svg") # the container
    @game_g       = @config.game_g      || d3.select("#game_g") # the container's main group
    @quadtree     = @config.quadtree    || null
    @tick         = @config.tick        || Physics.verlet # an update function; by default, assume that the force is independent of velocity i.e. f(x, v) = f(x)
    @is_removed = false
    @is_sleeping  = false
    @_cleanup     = true # call remove() when element goes offscreen by default
    Utils.addChainedAttributeAccessor(@, 'fill')
    Utils.addChainedAttributeAccessor(@, 'stroke')
        
  reaction: (element) -> # interface for reactions after a collision event with another element occurs 
    element?.reaction() # reactions occur in pairs so let one half of the pair trigger the other's reaction by default

  BB: ->
    @left   = @r.x - 0.5 * @bb_width
    @right  = @r.x + 0.5 * @bb_width
    @top    = @r.y - 0.5 * @bb_height
    @bottom = @r.y + 0.5 * @bb_height  

  draw: ->
    @g.attr("transform", "translate(" + @r.x + "," + @r.y + ") rotate(" + (360 * 0.5 * @angle / Math.PI) + ")")
    return
    
  remove_check: (n) ->
    if @is_root || @is_bullet
      @reaction(n) 
      return true
    false

  offscreen: -> @r.x < -@size or @r.y < -@size or @r.x > Game.width + @size or @r.y > Game.height + @size

  fadeIn: (dur = 30, callback) ->
    @g.transition()
    .duration(dur)
    .ease('linear')
    .style("opacity", 1)
    .each('end', => callback?(@))

  fadeOut: (dur = 30, callback) ->
    @g.transition()
    .duration(dur)
    .ease('linear')
    .style("opacity", 0)
    .each('end', => callback?(@))

  start: (duration = undefined, callback = undefined) ->
    if @is_sleeping
      console.log('element.start: is_removed or is_sleeping... bug?')
      return
    index = Collision.list.indexOf(@)
    if index == -1
      Collision.list.push(@) # tell physics module that this element wants to join
    else
      console.log('element.start: this element is already on the physics list! bug?')
    @is_removed = false  # mark the element as removeed
    @draw()
    @fadeIn(duration, callback)
    return

  cleanup: (@_cleanup = @_cleanup) ->
    return if @is_removed
    @remove() if @_cleanup and @offscreen()
    @is_removed

  sleep: ->
    Factory.sleep(@) # push this element onto the inactive array
    @is_sleeping = true # mark the element instance as asleep
    return

  remove: (fadeOutSwitch = true) -> # fade out element (opacity = 0) by default 
    return if @is_removed
    @is_removed = true # mark the element instance as removeed
    @fadeOut() if fadeOutSwitch
    @sleep() # put it back in the object pool for potential reuse later
    return

  spawn: ->
    @wake()
    @start()
    @
  
  init: ->
    @r.x  = 0
    @r.y  = 0
    @dr.x = 0
    @dr.y = 0
    @v.x  = 0
    @v.y  = 0
    @f.x  = 0
    @f.y  = 0  
    @

  wake: (config) ->
    @is_sleeping  = false  # mark the eleemnt as awake
    # restore default position, velocity, and force values:
    @init()
    Utils.set(@, config) if config?
    @ # return this element instance
    
  update: (fps) -> # helper to combine these three operations into one loop for efficiency    
    @tick?(@, fps) # the physics function takes the instance (self) as an input argument to avoid making unnecessary closures or deep-copies of the function
    @draw()
    return