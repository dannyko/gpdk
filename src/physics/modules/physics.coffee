class @Physics # numerical integration module for solving differential equations e.g. physical simulations
  @fps = 60 # ideal framerate according to the requestAnimFrame spec
#  @tick: 1000 / @fps # maximum frames per second to prevent the simulation from running too fast on faster machines for predictable realtime performance
  @off: false # a boolean switch determining whether or not to run the physics engine
  @timestamp: 0 # to keep track of integration frequency
  @game = null # initialize reference to game instance associated with the physics engine
  @callbacks = []
  @debug = false

#  window.requestAnimFrame =
#    window.requestAnimationFrame       || 
#    window.webkitRequestAnimationFrame || 
#    window.mozRequestAnimationFrame    || 
#    window.oRequestAnimationFrame      || 
#    window.msRequestAnimationFrame     || 
#    (callback, element) ->
#      window.setTimeout(callback, @tick)

  @verlet_step: (element, dt = element.dt) ->
    element.f.scale(0.5 * dt * dt)
    element.dr.x = element.v.x # initialize displacement vector
    element.dr.y = element.v.y # initialize displacement vector
    element.dr.scale(dt).add(element.f) # store displacement vector
    element.r.add(element.dr) # update position
    return if element.cleanup() # don't setup for the next update if element is destroyed
    element.fcopy.init(element.f) # copy this object for temporary storage
    element.f.x = 0 # initialize current force
    element.f.y = 0 # initialize current force
    accumulateSwitch = true # parameter for Force module
    element.force_param.forEach (param) -> # loop over force parameter array elements
      Force.eval(element, param, element.f, accumulateSwitch) # accumulate the forces acting on this element one at a time
    element.v.add(element.fcopy.add(element.f).scale(0.5 * dt)) # Verlet velocity update, assuming that the force is velocity-independent

  @verlet: (element, fps) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm
    if Physics.fps > fps # check if game is running slow and handle the remainder
      Nstep = Math.floor(Physics.fps / fps)
      step  = 0
      while step < Nstep # adjust the number of steps to take depending on the machine speed - slower machines should take more steps to maintain game difficulty
        Physics.verlet_step(element)
        ++step
    else
      diff = fps - Physics.fps # compute excess in framerate
      scale = diff / Physics.fps # relative error
      dt = element.dt / (1 + scale) # (make timestep smaller since we're running fast)
      Physics.verlet_step(element, dt) 
      return

  @integrate: (t) ->
    # console.log(Factory.active[Vec]?.length, Factory.active[Bullet]?.length) # leaktest
    return true if Physics.off
    # requestAnimFrame(Physics.integrate) # keep running the loop
    dt = if Physics.timestamp > 0 then (t - Physics.timestamp) else Physics.tick
    Physics.timestamp = t
    fps = 1000 / dt # instantaneous frames per second (noisy)
    console.log('fps: ' + fps) if Physics.debug
    len = Collision.list.length # update after requestAnimFrame to match 60 fps most closely when falling back to setTimeout (see http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/)
    Collision.list[len].update(fps) while (len--) # backwards to avoid reindexing issues from splice inside element.cleanup()
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    len = Physics.callbacks.length 
    while (len--) # backwards to avoid reindexing issues from splice inside element.cleanup()
      break if Physics.callbacks.length == 0
      bool = Physics.callbacks[len](t)
      if bool # returning a value of true means we can remove this callback
        if len < Physics.callbacks.length - 1 # reorder to put element to remove at the end
          swap = Physics.callbacks[Physics.callbacks.length - 1]
          Physics.callbacks[Physics.callbacks.length - 1] = Physics.callbacks[len]
          Physics.callbacks[len] = swap
        Physics.callbacks.pop()
    return
  
  @start: (game = undefined, delay = 0) -> 
    @off = false 
    d3.timer(Physics.integrate)
    return

  @stop: -> 
    @off = true
    return
