class @Physics # numerical integration module for solving differential equations e.g. physical simulations

  @off: false # a boolean switch determining whether or not to run the physics engine
  @tick: 1000 / 80 # maximum frames per second to prevent the simulation from running too fast on faster machines for predictable realtime performance
  @timestamp: Utils.timestamp() # to keep track of integration frequency
  @game = null # initialize reference to game instance associated with the physics engine

  @verlet: (element) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm
    -> # reference: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
      element.f.scale(0.5 * element.dt * element.dt)
      element.dr.x = element.v.x # initialize displacement vector
      element.dr.y = element.v.y # initialize displacement vector
      element.dr.scale(element.dt).add(element.f) # store displacement vector
      element.r.add(element.dr) # update position
      f = Factory.spawn(Vec, element.f) # copy this object for temporary storage
      element.f.x = 0 # initialize current force
      element.f.y = 0 # initialize current force
      element.force_param.forEach (param) -> 
        force = Force.eval(element, param)
        element.f.add(force) # evaluate and store force value with respect to the updated position
        Factory.sleep(force)
      element.v.add(f.add(element.f).scale(0.5 * element.dt)) # Verlet velocity update, assuming that the force is velocity-independent
      Factory.sleep(f)
      return      

  @integrate: (cleanup = true) =>
    console.log(Factory.active) # leaktest
    return true if @off
    timestamp = Utils.timestamp()
    return if timestamp - @timestamp < @tick # prevent the animation speed from running too fast
    @timestamp = timestamp
    len = Collision.list.length
    Collision.list[len].update() while (len--) # backwards to avoid reindexing issues from splice inside element.cleanup()
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    @game?.update_window() # if the game gives the physics engine a reference to itself, use it to keep the game's window updated
    return 
  
  @start: (game = undefined, delay = 0) -> 
    @game = game
    @off = false 
    d3.timer(@integrate, delay)
    return

  @stop: -> 
    @off = true
    return
