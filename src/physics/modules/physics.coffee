class @Physics # numerical integration module for solving differential equations e.g. physical simulations

  # class variables for convenient global access:
  @fps: 60 # ideal framerate according to the requestAnimFrame spec
  @tick: 1000 / Physics.fps # the natural/target frame length/duration for this game/visualization (per web animation standards)
  @off: false # a boolean switch determining whether or not to run the physics engine
  @game: null # initialize reference to game instance associated with the physics engine
  @callbacks: []
  @staging: [] # for elements that want to join the physics engine
  @debug: false

# for testing:
#  window.requestAnimFrame =
#    window.requestAnimationFrame       || 
#    window.webkitRequestAnimationFrame || 
#    window.mozRequestAnimationFrame    || 
#    window.oRequestAnimationFrame      || 
#    window.msRequestAnimationFrame     || 
#    (callback, element) ->
#      window.setTimeout(callback, Physics.tick)

  @verlet_step: (element, dt = element.dt) ->
    element.f.scale(0.5 * dt * dt)
    element.dr.x = element.v.x # initialize displacement vector
    element.dr.y = element.v.y # initialize displacement vector
    element.dr.scale(dt).add(element.f) # store displacement vector
    element.r.add(element.dr) # update position
    return if element.cleanup() # don't setup for the next update if element is removeed
    element.fcopy.init(element.f) # copy this object for temporary storage
    element.f.x = 0 # initialize current force
    element.f.y = 0 # initialize current force
    accumulateSwitch = true # parameter for Force module
    element.force_param.forEach (param) -> # loop over force parameter array elements
      Force.eval(element, param, element.f, accumulateSwitch) # accumulate the forces acting on this element one at a time
    element.v.add(element.fcopy.add(element.f).scale(0.5 * dt)) # Verlet velocity update, assuming that the force is velocity-independent
    return

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
      Physics.verlet_step(element) 
    return

  @integrate: (t) ->
    return true if Physics.off
    # requestAnimFrame(Physics.integrate) # keep running the loop
    if t > Physics.timestamp
      dt = t - Physics.timestamp
    else 
      dt = Physics.tick
    fps = 1000 / dt # instantaneous frames per second (noisy)
    if Physics.debug
      console.log('integrate:', 'dt: ', dt, 't: ', t, 'Physics.timestamp: ', Physics.timestamp, 'dt_chk: ', t - Physics.timestamp, 'fps: ' + fps)
    Physics.timestamp = t
    index = Physics.staging.length
    while index-- # bring the elements from the staging array into the physics engine
      if Collision.list.indexOf(Physics.staging[index]) == -1
        swap = Physics.staging[Physics.staging.length - 1]
        Physics.staging[Physics.staging.length - 1] = Physics.staging[index]
        Physics.staging[index] = swap
        Collision.list.push(Physics.staging.pop())
      else 
        console.log('staged element not removed', Physics.staging[Physics.staging.length - 1]) if Physics.debug
    Physics.update(fps)
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    index = Physics.callbacks.length 
    while (index--) # backwards to avoid reindexing issues from splice inside element.cleanup()
      break if Physics.callbacks.length is 0
      bool = Physics.callbacks[index](t)
      Utils.index_pop(Physics.callbacks, index) if bool # returning a value of true means we can remove this callback
    @off
  
  @update: (fps = Physics.fps) ->
    index = Collision.list.length # update after requestAnimFrame to match 60 fps most closely when falling back to setTimeout (see http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/)
    while (index--) # backwards to avoid reindexing issues from splice inside element.cleanup()
      if Collision.list[index].is_removed
        Utils.index_pop(Collision.list, index)
      else
        Collision.list[index].update(fps)  

  @start: -> 
    @off = false 
    @timestamp = 0 # to keep track of integration frequency
    d3.timer(@integrate)
    return

  @stop: -> 
    Physics.update() # flush elements waiting to be removed
    @off = true
    return