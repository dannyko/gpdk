class $z.Factory # a module that keeps track of unused instances to reduce garbage collection overhead from object creation / memory churn
  @inactive = {} # initialize object

  @spawn: (klass, config, callback) -> # only create a new object if one can't be reused, otherwise repurpose/reconfigure the reusable object
    if @inactive[klass] is undefined # check if any objects of this type have been created yet
      @inactive[klass] = [] # initialize array for this class $z.if no objects of this type have been created yet
    if @inactive[klass].length is 0 # check if any inactive objects of this type are available before creating a new one
      old = new klass(config) # only create a new object if no others are available (i.e. either uncreated or user did not user Factory to create them)
    else
      old = @inactive[klass].pop() # remove one of the inactive elements from the inactive list for re-use instead of creating a new object to reduce garbage collection
      if old.is_sleeping is false or old.is_removed is false
        console.log('$z.Factory.spawn: not sleeping & unremoved instance found in inactive list!', old)
        $z.Factory.spawn(klass, config) # toss this element our of the object pool and try spawning again
        return
      if old.wake?
        old.wake(config) # trigger reset function if newly spawned element was revived rather than created
      else # execute default action
        $z.Utils.set(old, config) # set instance parameters to config params
    callback?(old) # execute callback if provided
    old # now it's new; i.e., not really old anymore, despite its name

  @sleep: (instance) -> # inactivate the instance and add it to the inactive array for its class $z.type
    if instance is undefined # or instance.is_sleeping is true
      console.log('$z.Factory.sleep(): undefined input', instance)
      return
    if instance.is_sleeping is true
      console.log('$z.Factory.sleep(): sleeping instance', instance, @inactive[instance.constructor].indexOf(instance))
      return
    @inactive[instance.constructor]?.push(instance) # push the newly inactive instance onto the corresponding inactive list for this class
    return