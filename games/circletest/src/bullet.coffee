class @Bullet extends Circle
  constructor: (@config = {}) ->
    super
    @is_bullet = true
    @size = 3 # bullets should be set smaller than default elements
    @fill("#000")
    
  death_check: (n) -> 
    @death()
    n.death()
    true