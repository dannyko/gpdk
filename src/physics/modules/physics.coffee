class @Physics # numerical integration module for solving differential equations e.g. physical simulations

  @tick: 1000 / 60 # maximum frames per second to prevent the simulation from running too fast on faster machines for predictable realtime performance
  @off: false # a boolean switch determining whether or not to run the physics engine
  @timestamp: Utils.timestamp() # to keep track of integration frequency
  @game = null # initialize reference to game instance associated with the physics engine
  @callbacks = []

  window.requestAnimFrame =
    window.requestAnimationFrame       || 
    window.webkitRequestAnimationFrame || 
    window.mozRequestAnimationFrame    || 
    window.oRequestAnimationFrame      || 
    window.msRequestAnimationFrame     || 
    (callback, element) ->
      window.setTimeout(callback, @tick)

  @verlet: (element) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm
    -> # reference: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
      element.f.scale(0.5 * element.dt * element.dt)
      element.dr.x = element.v.x # initialize displacement vector
      element.dr.y = element.v.y # initialize displacement vector
      element.dr.scale(element.dt).add(element.f) # store displacement vector
      element.r.add(element.dr) # update position
      return if element.cleanup() # don't setup for the next update if element is destroyed
      f = Factory.spawn(Vec, element.f) # copy this object for temporary storage
      element.f.x = 0 # initialize current force
      element.f.y = 0 # initialize current force
      force = Factory.spawn(Vec) # initialize temporary variable to store each force component's value
      element.force_param.forEach (param) -> 
        Force.eval(element, param, force) # assign force component to temporary force variable
        element.f.add(force) # accumulate the forces acting on this element one at a time
      Factory.sleep(force) # deactivate the temporary variable to conserve memory/reduce GC overhead
      element.v.add(f.add(element.f).scale(0.5 * element.dt)) # Verlet velocity update, assuming that the force is velocity-independent
      Factory.sleep(f)
      return      

  @integrate: (cleanup = true) ->
    # console.log(Factory.active[Vec]?.length, Factory.active[Bullet]?.length) # leaktest
    return true if Physics.off
    requestAnimFrame(Physics.integrate) # keep running the loop
    len = Collision.list.length # update after requestAnimFrame to match 60 fps most closely when falling back to setTimeout (see http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/)
    Collision.list[len].update() while (len--) # backwards to avoid reindexing issues from splice inside element.cleanup()
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    Physics.callbacks.forEach((d) -> d())
    # Physics.game?.update_window() # if the game gives the physics engine a reference to itself, use it to keep the game's window updated
  
  @start: (game = undefined, delay = 0) -> 
    @game = game
    @off = false 
    @integrate()
    return

  @stop: -> 
    @callbacks = []
    @off = true
    return
