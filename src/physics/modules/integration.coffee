class @Integration # numerical integration module for solving differential equations e.g. physical simulations

  @off: false # a boolean switch determining whether or not to run the 
  @tick: (33 + 1/3) # maximum frames per second to prevent the simulation from running too fast on faster machines for predictable realtime performance
  @timestamp: Utils.timestamp() # to keep track of integration frequency

  @verlet: (element) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm
    -> # reference: http://en.wikipedia.org/wiki/Verlet_integration#Velocity_Verlet
      r = new Vec(element.r) # clone the current position vector object for later comparison
      f = element.force.f(r) # evaluate the force at the current position
      element.r.add(new Vec(element.v).scale(element.dt)).add(new Vec(f).scale(0.5 * element.dt * element.dt)) # update position
      element.f = element.force.f(element.r) # evaluate and store force value with respect to the updated position
      element.v.add(f.add(element.f).scale(0.5 * element.dt)) # Verlet velocity update, assuming that the force is velocity-independent
      if r.x isnt element.r.x or r.y isnt element.r.y # check for position change
        element.draw() # force draw before checking for collision
      return      

  @integrate: ->
    return true if @off
    timestamp = Utils.timestamp()
    return if timestamp - @timestamp < @tick # prevent the animation speed from running too fast
    console.log(timestamp - @timestamp, @tick)
    @timestamp = timestamp
    moveable = _.filter(Collision.list, (d) -> not d.fixed) # select elements bound to the physics engine that are subject to some physical laws of motion 
    element.tick() for element in moveable # update each element by one tick of its timestep element.dt
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    return 
  
  @start: (delay = 0) -> 
    @off = false 
    d3.timer(@integrate, delay)
    return

  @stop: -> 
    @off = true
    return