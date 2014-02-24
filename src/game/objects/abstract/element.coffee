class @Element
  constructor: (@config = {}) ->      
    @dt           = @config.dt          || 0.4 # controls displacement of Physics engine relative to the framerate
    @r            = @config.r           || Factory.spawn(Vec) # position vector (rx, ry)
    @dr           = @config.dr          || Factory.spawn(Vec) # displacement vector (dx, dy)
    @v            = @config.v           || Factory.spawn(Vec) # velocity vector (vx, vy)
    @f            = @config.f           || Factory.spawn(Vec) # force vector (fx, fy)
    @n            = @config.n           || [] # array of references to neighbor elements that this element interacts with
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
    @g            = @config.g           || @g
    @svg          = @config.svg         || d3.select("#game_svg") # the container
    @game_g       = @config.game_g      || d3.select("#game_g") # the container's main group
    @quadtree     = @config.quadtree    || null
    @tick         = @config.tick        || Physics.verlet # an update function; by default, assume that the force is independent of velocity i.e. f(x, v) = f(x)
    @is_destroyed = false
    @is_sleeping  = false
    @_cleanup     = true # call destroy() when element goes offscreen by default
    Utils.addChainedAttributeAccessor(@, 'fill')
    Utils.addChainedAttributeAccessor(@, 'stroke')
        
  reaction: (element) -> # interface for reactions after a collision event with another element occurs 
    element.reaction() if element?  # reactions occur in pairs so let one half of the pair trigger the other's reaction by default

  BB: ->
    @left   = @r.x - 0.5 * @bb_width
    @right  = @r.x + 0.5 * @bb_width
    @top    = @r.y - 0.5 * @bb_height
    @bottom = @r.y + 0.5 * @bb_height  

  draw: ->
    @g.attr("transform", "translate(" + @r.x + "," + @r.y + ") rotate(" + (360 * 0.5 * @angle / Math.PI) + ")")
    return
    
  destroy_check: (n) ->
    if @is_root || @is_bullet
      @reaction(n) 
      return true
    false

  offscreen: -> @r.x < -@size or @r.y < -@size or @r.x > Game.width + @size or @r.y > Game.height + @size

  start: ->
    if @is_sleeping
      console.log('element.start: is_destroyed or is_sleeping', @)
    index = Collision.list.indexOf(@)
    if index > -1
      console.log('element.start: already on physics list!', @)
    else
      Collision.list.push(@) # add element to collision list by default unless it's already there
      @is_destroyed = false  # mark the element as destroyed
      @draw()
      @g.style('opacity', 1)
    return

  stop: -> 
    index = Collision.list.indexOf(@)
    if index > -1
      if Collision.list.length > 1
        swap  = Collision.list[index]
        Collision.list[index] = Collision.list[Collision.list.length - 1]
        Collision.list[Collision.list.length - 1] = swap
      Collision.list.pop()
    return

  cleanup: (@_cleanup = @_cleanup) ->
    return if @is_destroyed
    @destroy() if @_cleanup and @offscreen()
    @is_destroyed

  sleep: ->
    Factory.sleep(@) # push this element onto the inactive array
    @is_sleeping = true # mark the element instance as asleep
    return

  destroy: (remove = false) -> # destroying with remove = false is the same as sleeping plus setting is_destroyed = true.
    @g.style('opacity', 0)
    @stop() # decouple the element from the physics engine
    @sleep() # put it back in the object pool for potential reuse later
    @is_destroyed = true # mark the element instance as destroyed
    return
  
  wake: (config) ->
    @is_sleeping  = false  # mark the eleemnt as awake
    # restore default position, velocity, and force values:
    @r.x  = 0
    @r.y  = 0
    @dr.x = 0
    @dr.y = 0
    @v.x  = 0
    @v.y  = 0
    @f.x  = 0
    @f.y  = 0
    Utils.set(@, config) if config?
    @ # return this element instance
    
  update: (fps) -> # helper to combine these three operations into one loop for efficiency    
    @tick(@, fps) # the physics function takes the instance (self) as an input argument to avoid making unnecessary closures or deep-copies of the function
    @draw()