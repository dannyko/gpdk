class Physics # numerical integration module for solving differential equations e.g. physical simulations

  # class variables for convenient global access:
  @fps: 240 # set physics framerate to be 4x the standard requestAnimationFrame rate (60 fps) to reduce the likelihood large per-frame displacements (jumps) 
  @elapsedTime: 0 # keeps track of how much time has elapsed since the last animation frame was called
  @tick: 1000 / Physics.fps # the natural/target frame length/duration for this game/visualization (per web animation standards)
  @off: true # a boolean switch determining whether or not to run the physics engine
  @game: null # initialize reference to game instance associated with the physics engine
  @callbacks: []
  @debug: false
  @timestamp: undefined
  @paused: false

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
    return if element.cleanup() # don't setup for the next update if element is removed
    element.fcopy.init(element.f) # copy this object for temporary storage
    element.f.x = 0 # initialize current force
    element.f.y = 0 # initialize current force
    accumulateSwitch = true # parameter for Force module
    element.force_param.forEach (param) -> # loop over force parameter array elements
      Force.eval(element, param, element.f, accumulateSwitch) # accumulate the forces acting on this element one at a time
    element.v.add(element.fcopy.add(element.f).scale(0.5 * dt)) # Verlet velocity update, assuming that the force is velocity-independent
    return

  @verlet: (element, elapsedTime) -> # default algorithm simulates Newtonian dynamics using approximate velocity Verlet algorithm 
    # integral time step(s):
    Nstep = Math.floor(elapsedTime / Physics.tick) # compute number of integral steps to take (slower computer => more physics steps per frame)
    step  = 0 # initialize step counter
    while step < Nstep # adjust the number of steps to take depending on the machine speed - slower machines should take more steps to maintain game difficulty
      Physics.verlet_step(element)
      ++step
    # fractional time step:
    error  = (elapsedTime - Nstep * Physics.tick) / Physics.tick # relative error in animation speed due to noise
    dt     = element.dt * error # scale timestep of physics to compensate for noise in framerate
    Physics.verlet_step(element, dt) # substep to compensate for slop in timing
    return

  @integrate: (t) ->
    return true if Physics.off
    # requestAnimFrame(Physics.integrate) # keep running the loop
    elapsedTime = t - Physics.timestamp
    Physics.elapsedTime = elapsedTime
    if Physics.debug
      fps = 1000 / elapsedTime # instantaneous frames per second (noisy)
      console.log('Physics.integrate:', 'dt: ', elapsedTime, 't: ', t, 'timestamp: ', Physics.timestamp, 'dt_chk: ', t - Physics.timestamp, 'fps: ' + fps)
    Physics.timestamp = t
    Physics.update(elapsedTime)
    Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    index = Physics.callbacks.length 
    while (index--) # backwards to avoid reindexing issues from splice inside element.cleanup()
      break if Physics.callbacks.length is 0
      bool = Physics.callbacks[index](t) # execute the callback
      Utils.index_pop(Physics.callbacks, index) if bool # returning a value of true means we can remove this callback
    @off
  
  @update: (elapsedTime = Physics.elapsedTime) ->
    index = Collision.list.length # update after requestAnimFrame to match 60 fps most closely when falling back to setTimeout (see http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/)
    while (index--) # iterate backwards to avoid indexing/variable array length issues, caused by removing elements from the array as we go
      if Collision.list[index].is_removed
        Utils.index_pop(Collision.list, index).sleep() # place this element into the object pool for potential reuse later
      else
        Collision.list[index].update(elapsedTime)
        if Physics.debug
          console.log('Physics.update', 'index:', index, 'fps:', fps, 'r.x:', Collision.list[index].r.x, 'r.y:', Collision.list[index].r.y)

  @start: -> 
    return unless @off # don't start twice
    @off = false 
    @timestamp = 0 # to keep track of integration frequency
    d3.timer(@integrate)
    blurCallback = -> # window loses focus
      Physics.paused = true
      Physics.stop()
    $(window).blur( null )
    $(window).focus( null )
    $(window).blur( blurCallback )
    $(window).focus( -> # window regains focus
      return unless Physics.paused
      if Gamescore.lives >= 0
        Game.instance.message('GET READY', ->
          Physics.timestamp = 0
          Physics.start()
          Physics.paused = false
        )
    )
    return

  @stop: -> 
    return if @off
    @off = true
    setTimeout(Physics.update, 2 * Physics.tick) # flush elements waiting to be removed
    return