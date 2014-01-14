class @Factory # a module that keeps track of unused instances to reduce garbage collection overhead from object creation / memory churn
  @active = {} # initialize the object that stores the arrays of used and unused objects of each type
  @inactive = {} # initialize object

  @spawn: (klass, config) -> # only create a new object if one can't be reused, otherwise repurpose/reconfigure the reusable object
    if @active[klass] is undefined # check if any objects of this type have been created yet
      @active[klass] = [] # initialize aray for this class if no objects of this type have been created yet
    if @inactive[klass] is undefined # check if any objects of this type have been created yet
      @inactive[klass] = [] # initialize array for this class if no objects of this type have been created yet
    if @inactive[klass].length is 0 # check if any inactive objects of this type are available before creating a new one
      @active[klass].push(new klass(config)) # only create a new object if no others are available (i.e. either uncreated or user did not user Factory to create them)
    else
      old = @inactive[klass].pop() # remove one of the inactive elements from the inactive list for re-use instead of creating a new object to reduce garbage collection
      for x of config # set the new configuration values for the object to prepare it for its new role
        old[x] = config[x] # set configuration value
      @active[klass].push(old) # push newly repurposed object onto active list
    return @active[klass][@active[klass].length - 1]

  @sleep: (instance) -> # inactivate the instance and add it to the inactive array for its class type
    if instance is undefined
      console.log('Factory.sleep(): undefined input')
    index = @active[instance.constructor].indexOf(instance) # compute the index of the element we want to remove from the active array
    if index == -1 # user asked for us to inactivate an object that was not created using the Factory! 
      console.log('Factory.sleep(): undefined index', instance) # should not happen unless user does not know what they're doing
      @inactive[instance.constructor].push(instance) # add it to the inactive list anyway even though they might not use it again (potential memory leak issue?)
    else
	    old   = @active[instance.constructor][index] # temporary/swap variable
	    if old is undefined
	      console.log('Factory.sleep(): undefined old', index, @active[instance.constructor])
	    if index is @active[instance.constructor].length - 1 # the instance we want to remove from the active list is the last one
	      @active[instance.constructor].pop() # remove the instance from the active list
	    else # the instance we want to remove is not the last element of the "active" array for this klass
	      @active[instance.constructor][index] = @active[instance.constructor].pop() # remove last element of the array and swap it with the one we want to remove
	    @inactive[instance.constructor].push(old) # push the newly inactive instance onto the corresponding inactive list for this class
	  undefined