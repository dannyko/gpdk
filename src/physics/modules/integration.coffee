class @Integration # numerical integration module for solving differential equations e.g. physical simulations

  @off: false # a boolean switch determining whether or not to run the 
  @tick: 1 / 120 # maximum frames per second to prevent the simulation from running too fast on faster machines for predictable realtime performance
  @timestamp: Utils.timestamp() # to keep track of integration frequency

  @verlet: (element) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm
    -> # reference: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
      f = element.force.f(element.r) # evaluate the force at the current position and store in temporary variable
      element.dr = new Vec(element.v).scale(element.dt).add(new Vec(f).scale(0.5 * element.dt * element.dt)) # store displacement vector
      element.r.add(element.dr) # update position
      element.f = element.force.f(element.r) # evaluate and store force value with respect to the updated position
      element.v.add(f.add(element.f).scale(0.5 * element.dt)) # Verlet velocity update, assuming that the force is velocity-independent
      return      

  @integrate: =>
    return true if @off
    timestamp = Utils.timestamp()
    return if timestamp - @timestamp < @tick # prevent the animation speed from running too fast
    @timestamp = timestamp
    moveable = _.filter(Collision.list, (d) -> not d.fixed) # select elements bound to the physics engine that are subject to some physical laws of motion 
    element.tick() for element in moveable # update each element by one tick of its timestep element.dt
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    element.draw() for element in moveable # redraw elements after their reactions have been taken into account
    return 
  
  @start: (delay = 0) -> 
    @off = false 
    d3.timer(@integrate, delay)
    return

  @stop: -> 
    @off = true
    return