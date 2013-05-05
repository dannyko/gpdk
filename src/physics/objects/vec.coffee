class @Vec # two-dimensional vectors {x, y}
  constructor: (@config = {}) ->
    @x = @config.x || 0
    @y = @config.y || 0 
  
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
   c = Math.cos(a)
   s = Math.sin(a)
   [@x, @y] = [c * @x - s * @y, @y = s * @x + c * @y]
   
  dot: (v) ->
    @x * v.x + @y * v.y

  length2: ->
    @dot(@)
   
  length: ->
    Math.sqrt(@length2())
    
  normalize: ->
    inverseLength = 1 / @length()
    @x *= inverseLength
    @y *= inverseLength
    @

  dist2: (v) ->
    new Vec(@).subtract(v).length2()
    
  dist: (v) ->
    Math.sqrt(@dist2(v))