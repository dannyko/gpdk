class $z.Element
  constructor: (@config = {}) ->      
    @d            = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @ri           = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @rj           = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @r_temp       = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @dr_temp      = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @line         = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @normal       = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @lshift       = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @vPar         = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @vPerp        = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @uPar         = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine
    @uPerp        = $z.Factory.spawn($z.Vec) # temporary vector used by the physics engine    
    @dt           = @config.dt             || 0.25 # controls displacement of physics engine relative to the framerate
    @r            = @config.r              || $z.Factory.spawn($z.Vec) # position vector (rx, ry)
    @dr           = @config.dr             || $z.Factory.spawn($z.Vec) # displacement vector (dx, dy)
    @v            = @config.v              || $z.Factory.spawn($z.Vec) # velocity vector (vx, vy)
    @f            = @config.f              || $z.Factory.spawn($z.Vec) # force vector (fx, fy)
    @fcopy        = $z.Utils.clone(@config.f) || $z.Factory.spawn($z.Vec) # copy of force vector (fx, fy) to speed up physics computations
    @force_param  = @config.force_param    || [] # array of objects for computing net force vectors 
    @size         = @config.size           || 0 # zero default size in units of pixels for abstract class
    @bb_width     = @config.bb_width       || 0 # bounding box width
    @bb_height    = @config.bb_height      || 0 # bounding box height
    @left         = @config.bb_width       || 0 # bounding box left
    @right        = @config.bb_height      || 0 # bounding box right
    @top          = @config.top            || 0 # bounding box top
    @bottom       = @config.bottom         || 0 # bounding box bottom
    @collision    = @config.collision      || true # element is created and exists in memory but is not part of the game (i.e. staged to enter or exit)
    @tol          = @config.tol            || 0.25 # default tolerance for collision resolution i.e. padding when updating positions to resolve conflicts
    @_stroke      = @config.stroke         || "none" # use underscore to avoid namespace collision with getter/setter method @stroke()
    @_fill        = @config.fill           || "black" # use underscore to avoid namespace collision with getter/setter method @fill()
    @angle        = @config.angle          || 0 # angle for rigid body rotation
    @is_root      = @config.is_root        || false # default boolean for root element control
    @is_bullet    = @config.is_bullet      || false # default boolean for bullet effects
    @type         = @config.type           || null # default type is null for abstract class
    @image        = @config.image          || null # no image by default for generic element: user must specify
    @overlay      = @config.overlay        || null
    @g            = d3.select("#game_g")
                    .append("g")
                    .attr("transform", "translate(" + @r.x + "," + @r.y + ")")
                    .style('opacity', 0)
                    .datum(@) # use the d3 "datum" function to "bind" the game element to the <g> tag to allow accessing the object via the DOM element/d3 selection
    @g            = @config.g              || @g
    @svg          = @config.svg            || $z.Game.instance.svg # the container
    @game_g       = @config.game_g         || $z.Game.instance.g # the container's main group
    @quadtree     = @config.quadtree       || null
    @tick         = @config.tick           || $z.Physics.verlet # an update function; by default, assume that the force is independent of velocity i.e. f(x, v) = f(x)
    @is_removed   = false
    @is_sleeping  = false
    @is_flashing  = false
    @_cleanup     = true # call remove() when element goes offscreen by default
    $z.Utils.addChainedAttributeAccessor(@, 'fill')
    $z.Utils.addChainedAttributeAccessor(@, 'stroke')
        
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

  offscreen: -> @r.x < -@size or @r.y < -@size or @r.x > $z.Game.width + @size or @r.y > $z.Game.height + @size

  fadeIn: (dur = 30, callback) ->
    if dur?
      @g.transition()
        .duration(dur)
        .ease('linear')
        .style("opacity", 1)
        .each('end', (d) -> callback?(d))
    else
      @g.style("opacity", 1)
      callback?(@)

  fadeOut: (dur = 30, callback) ->
    @g.transition()
      .duration(dur)
      .ease('linear')
      .style("opacity", 0)
      .each('end', (d) -> callback?(d))

  flash: (dur = 1000, color = '#FFF', scaleFactor = 3, initialOpacity = 0.4) ->
    return if @is_flashing # wait until previous flash finishes
    @is_flashing = true
    @overlay
      .style('fill', color)
      .style('opacity', initialOpacity)
      .transition()
      .duration(dur)
      .attr('transform', 'scale(' + scaleFactor + ')')
      .style('opacity', 0)
      .ease('linear')
      .each('end', =>  # use double arrow since we don't know if user has bound the data (@) to the overlay element
        @overlay.attr('transform', 'scale(1)')
        @is_flashing = false
      )

  start: (duration = undefined, callback = => @collision = true) ->
    if @is_sleeping
      console.log('element.start: is_sleeping... bug?')
      return
    index = $z.Collision.list.indexOf(@)
    if index == -1
      $z.Collision.list.push(@) # tell physics module that this element wants to join
    else
      console.log('element.start: this element is already on the physics list! bug?')
    @is_removed = false  # mark the element as removed
    @draw()
    @fadeIn(duration, callback)
    return

  cleanup: (@_cleanup = @_cleanup) ->
    @remove() if @_cleanup and @offscreen()

  sleep: ->
    $z.Factory.sleep(@) # push this element onto the inactive array
    @is_sleeping = true # mark the element instance as asleep
    return

  remove: (dur = 30) -> # fade out element (opacity = 0) by default 
    return if @is_removed or not @collision
    @collision = false
    if dur > 0
      @fadeOut(dur, ((d) -> d.is_removed = true))
    else
      @is_removed = true # important detail: mark the element instance as removed but let the physics engine call sleep() to avoid inconsistent data!    
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
    $z.Utils.set(@, config) if config?
    @ # return this element instance
    
  update: (elapsedTime) -> # helper to combine these three operations into one loop for efficiency    
    @tick?(@, elapsedTime) # the physics function takes the instance (self) as an input argument to avoid making unnecessary closures or deep-copies of the function
    @draw()
    return

  scale: (scalingFactor = 10, dur = undefined, callback = ->) ->
    if dur?
      @image
       .transition()
       .duration(dur)
       .ease('linear')
       .attr('transform', 'scale(' + scalingFactor + ')')
       .each('end', callback)
    else
      @image.attr('transform', 'scale(' + scalingFactor + ')')
      callback()