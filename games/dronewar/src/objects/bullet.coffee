class @Bullet extends Circle
  constructor: (@config = {}) ->
    super
    @is_bullet = true
    @size = 3 # bullets should be set smaller than default elements
    @fill("#000")
    
  death: -> # bullet handles score value updates 
    @deactivate()
    @g.remove()      
    Gamescore.increment_value() 
    Gameprez.score("player", Gamescore.value) if Gameprez?