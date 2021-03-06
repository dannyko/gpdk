class $z.Vec # two-dimensional vectors {x, y}
  constructor: (@config = {}) ->
    @x = @config.x || 0
    @y = @config.y || 0 

  init: (v = {x: 0, y: 0}) ->
    @x = v.x
    @y = v.y
    @
  
  scale: (c) ->
    @x *= c
    @y *= c
    @

  add: (v) ->
    @x += v.x
    @y += v.y
    @
    
  subtract: (v) ->
    @x -= v.x
    @y -= v.y
    @
  
  rotate: (a) ->
   c  = Math.cos(a)
   s  = Math.sin(a)
   @x = c * @x - s * @y
   @y = s * @x + c * @y
   @
   
  dot: (v) ->
    @x * v.x + @y * v.y

  length_squared: ->
    @dot(@)
   
  length: ->
    Math.sqrt(@length_squared())
    
  normalize: (length = 1) ->
    inverseLength = length / @length()
    @x *= inverseLength
    @y *= inverseLength
    @

  dist_squared: (v) ->
    dx = @x - v.x
    dy = @y - v.y
    dx * dx + dy * dy
    
  dist: (v) ->
    Math.sqrt(@dist_squared(v))