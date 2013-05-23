class @Element
  constructor: (@config = {}) ->      
    @dt        = @config.dt        || 0.4 # controls animation smoothness relative to d3.timer queue update rate
    @r         = @config.r         || new Vec() # position vector (rx, ry)
    @dr        = @config.dr        || new Vec() # displacement vector (dx, dy)
    @v         = @config.v         || new Vec() # velocity vector (vx, vy)
    @f         = @config.f         || new Vec() # force vector (fx, fy)
    @n         = @config.n         || [] # array of references to neighbor elements that this element interacts with
    @force     = @config.force     || [new Force()] # array of objects for computing net force vectors: force.f() = [fx, fy]
    @size      = @config.size      || 0 # zero default size in units of pixels for abstract class
    @bb_width  = @config.bb_width  || 0 # bounding box width
    @bb_height = @config.bb_height || 0 # bounding box height
    @left      = @config.bb_width  || 0 # bounding box left
    @right     = @config.bb_height || 0 # bounding box right
    @top       = @config.top       || 0 # bounding box top
    @bottom    = @config.bottom    || 0 # bounding box bottom
    @collision = @config.collision || true # element is created and exists in memory but is not part of the game (i.e. staged to enter or exit)
    @tol       = @config.tol       || 0.5 # default tolerance for collision resolution i.e. padding when updating positions to resolve conflicts
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
    @tick      = @config.tick      || Integration.verlet(@) # an update function; by default, assume that the force is independent of velocity i.e. f(x, v) = f(x)
    @width     = parseInt(@svg.attr("width"))
    @height    = parseInt(@svg.attr("height"))
    @destroyed = false
    @_cleanup  = true # call destroy() when element goes offscreen by default
    Utils.addChainedAttributeAccessor(@, 'fill')
    Utils.addChainedAttributeAccessor(@, 'stroke')
    @start() # constructor calls start() by default, binding the element to the physics engine (which may not be on yet)
        
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

  offscreen: -> @r.x < -@size or @r.y < -@size or @r.x > @width + @size or @r.y > @height + @size

  start: ->  
    Collision.list.push(@) # add element to collision list by default
    return

  stop: -> 
    index = _.indexOf(Collision.list, @)
    Collision.list.splice(index, 1) if index > -1
    return

  cleanup: (@_cleanup = @_cleanup) ->
    @destroy() if @_cleanup and @offscreen()
    return

  destroy: (remove = true) -> 
    @stop()
    @destroyed = true
    @g.remove() if remove # avoids accumulating indefinite numbers of dead elements
    return