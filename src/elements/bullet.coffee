class @Bullet extends Circle
  constructor: (@config = {}) ->
    super
    @size = 3 # bullets should be set smaller than default elements
    @fill("#000")