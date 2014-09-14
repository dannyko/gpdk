class $z.Physics # numerical integration module for solving differential equations e.g. physical simulations

  # class $z.variables for convenient global access:
  @fps = 240 # set physics framerate to be 4x the standard requestAnimationFrame rate (60 fps) to reduce the likelihood large per-frame displacements (jumps) 
  @elapsedTime = 0 # keeps track of how much time has elapsed since the last animation frame was called
  @tick = 1000 / Physics.fps # the natural/target frame length/duration for this game/visualization (per web animation standards)
  @maxElapsedTime = 100 * @tick # longest allowed duration between frames
  @Nstep = 2
  @off = true # a boolean switch determining whether or not to run the physics engine
  @game = null # initialize reference to game instance associated with the physics engine
  @callbacks = []
  @debug = false
  @timestamp = undefined
  @paused = false

# for testing:
#  window.requestAnimFrame =
#    window.requestAnimationFrame       || 
#    window.webkitRequestAnimationFrame || 
#    window.mozRequestAnimationFrame    || 
#    window.oRequestAnimationFrame      || 
#    window.msRequestAnimationFrame     || 
#    (callback, element) ->
#      window.setTimeout(callback, Physics.tick)

  @euler = (element, dt = Physics.tick) ->
    return if element.cleanup() # don't setup for the next update if element is removed
    element.f.x = 0 # initialize current force
    element.f.y = 0 # initialize current force
    accumulateSwitch = true # parameter for $z.Force module
    element.force_param.forEach (param) -> # loop over force parameter array elements
      $z.Force.eval(element, param, element.f, accumulateSwitch) # accumulate the forces acting on this element one at a time
    element.v.add(element.f.scale(dt)) # velocity update, assuming that the force is velocity-independent
    element.dr.init(element.v).scale(dt) # compute displacement vector
    element.r.add(element.dr) # update position
    return

  @integrate = (t) ->
    return true if Physics.off
    # requestAnimFrame(Physics.integrate) # keep running the loop
    Physics.elapsedTime = t - Physics.timestamp
    if Physics.elapsedTime > Physics.maxElapsedTime
      dur = 2000
      Physics.stop()
      $z.Game.instance.message(
        'CPU SPEED ERROR'
        -> $z.Game.instance.stop()
        dur
      )
    if Physics.debug
      fps = 1000 / elapsedTime # instantaneous frames per second (noisy)
      console.log('Physics.integrate:', 'dt: ', elapsedTime, 't: ', t, 'timestamp: ', Physics.timestamp, 'dt_chk: ', t - Physics.timestamp, 'fps: ' + fps)
    Physics.timestamp = t
    Physics.update()
    return Physics.off
  
  @update = ->
    Physics.step()
    $z.Collision.detect() # detect all collisions between active elements and execute their corresonding reactions
    Physics.draw_all()
    Physics.run_callbacks()

  @step = () -> # one full step of the physics engine - update all elements, resolve collisions, etc.
    stepCount = 0
    while stepCount < Physics.Nstep
      stepCount++
      index = $z.Collision.list.length # update after requestAnimFrame to match 60 fps most closely when falling back to setTimeout (see http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/)
      while (index--) # iterate backwards to avoid indexing/variable array length issues, caused by removing elements from the array as we go
        if $z.Collision.list[index].is_removed
          $z.Utils.index_pop($z.Collision.list, index).sleep() # place this element into the object pool for potential reuse later
        else
          element = $z.Collision.list[index]
          element.tick(element, Physics.elapsedTime / Physics.Nstep)
          if Physics.debug
            console.log('Physics.update', 'index:', index, 'fps:', fps, 'r.x:', $z.Collision.list[index].r.x, 'r.y:', $z.Collision.list[index].r.y)

  @run_callbacks = ->
    index = Physics.callbacks.length 
    while (index--) # backwards to avoid reindexing issues from splice inside element.cleanup()
      break if Physics.callbacks.length is 0
      bool = Physics.callbacks[index](Physics.timestamp) # execute the callback
      $z.Utils.index_pop(Physics.callbacks, index) if bool # returning a value of true means we can remove this callback

  @draw_all = ->
    index = $z.Collision.list.length 
    while (index--) # backwards to avoid reindexing issues from splice inside element.cleanup()  
      element = $z.Collision.list[index]
      element.draw()

  @start = -> 
    return unless Physics.off # don't start twice
    Physics.off = false 
    Physics.timestamp = 0 # to keep track of integration frequency
    d3.timer(Physics.integrate)
    blurCallback = -> # window loses focus
      Physics.paused = true
      Physics.stop()
    $(window).blur( null )
    $(window).focus( null )
    $(window).blur( blurCallback )
    $(window).focus( -> # window regains focus
      return unless Physics.off
      Physics.paused = false
      if $z.Gamescore.lives >= 0
        $z.Game.instance.message('GET READY', ->
          return if Physics.paused
          Physics.timestamp = 0
          Physics.start()
        )
    )
    return

  @stop = -> 
    return if Physics.off
    Physics.off = true
    Physics.timestamp = undefined # reset to prevent big jumps
    setTimeout(Physics.update, 2 * Physics.tick) # flush elements waiting to be removed
    return