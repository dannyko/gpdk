class @Gamescore # gamescore module 

  ## class variables:
  @value = 0 # default initial game score
  @increment = 100 # default score increment
  @initialLives = 1 # default number of extra lives
  @lives  = @initialLives # i.e. 3 lives total by default including the starting element

  ## class methods:
  @increment_value: -> # increase the value by the increment
    @value += @increment # update current game score value

  @decrement_value: -> # increase the value by the increment
    @value -= @increment # update current game score value