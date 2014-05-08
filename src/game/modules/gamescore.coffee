class $z.Gamescore # gamescore module 

  ## class $z.variables:
  @value = 0 # default initial game score
  @increment = 100 # default score increment
  @initialLives = 2 # default number of extra lives
  @lives  = @initialLives # i.e. 3 lives total by default including the starting element

  ## class $z.methods:
  @increment_value: -> # increase the value by the increment
    @value += @increment # update current game score value

  @decrement_value: -> # increase the value by the increment
    @value -= @increment # update current game score value