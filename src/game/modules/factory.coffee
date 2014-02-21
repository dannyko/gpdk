class @Factory # a module that keeps track of unused instances to reduce garbage collection overhead from object creation / memory churn
  @inactive = {} # initialize object

  @spawn: (klass, config) -> # only create a new object if one can't be reused, otherwise repurpose/reconfigure the reusable object
    if @inactive[klass] is undefined # check if any objects of this type have been created yet
      @inactive[klass] = [] # initialize array for this class if no objects of this type have been created yet
    if @inactive[klass].length is 0 # check if any inactive objects of this type are available before creating a new one
      return (new klass(config)) # only create a new object if no others are available (i.e. either uncreated or user did not user Factory to create them)
    else
      old = @inactive[klass].pop() # remove one of the inactive elements from the inactive list for re-use instead of creating a new object to reduce garbage collection
      old.wake?() # trigger reset function if newly spawned element was revived rather than created
      for x of config # set the new configuration values for the object to prepare it for its new role
        old[x] = config[x] # set configuration value
    return old # new; not old anymore

  @sleep: (instance) -> # inactivate the instance and add it to the inactive array for its class type
    if instance is undefined
      console.log('Factory.sleep(): undefined input')
      return
    @inactive[instance.constructor].push(instance) # push the newly inactive instance onto the corresponding inactive list for this class
    return