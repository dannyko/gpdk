class @Physics # numerical integration module for solving differential equations e.g. physical simulations

  @off: false # a boolean switch determining whether or not to run the physics engine
  @tick: 1000 / 80 # maximum frames per second to prevent the simulation from running too fast on faster machines for predictable realtime performance
  @timestamp: Utils.timestamp() # to keep track of integration frequency
  @game = null # initialize reference to game instance associated with the physics engine

  @verlet: (element) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm
    -> # reference: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
      element.dr = new Vec(element.v).scale(element.dt).add(new Vec(element.f).scale(0.5 * element.dt * element.dt)) # store displacement vector
      element.r.add(element.dr) # update position
      f = new Vec() ; element.force_param.forEach (param) -> f.add(Force.eval(element, param)) # evaluate and store force value with respect to the updated position
      element.v.add(f.add(element.f).scale(0.5 * element.dt)) # Verlet velocity update, assuming that the force is velocity-independent
      element.f = f
      return      

  @integrate: (cleanup = true) =>
    return true if @off
    timestamp = Utils.timestamp()
    return if timestamp - @timestamp < @tick # prevent the animation speed from running too fast
    @timestamp = timestamp
    len = Collision.list.length
    Collision.list[len].update() while (len--) # backwards to avoid reindexing issues from splice inside element.cleanup()
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    @game?.update_window() # if the game gives the physics engine a reference to itself, use it to keep the game's window updated
    return 
  
  @start: (game, delay = 0) -> 
    @game = game
    @off = false 
    d3.timer(@integrate, delay)
    return

  @stop: -> 
    @off = true
    return
