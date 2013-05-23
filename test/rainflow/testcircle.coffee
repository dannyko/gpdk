class @TestCircle extends Circle
  constructor: (@config = {}) ->
    super
    @dt = 1e-2
    @size = 2.5
    @fill('lightgray')
    @image.attr('opacity', '0.8')
    # @BB() to allow bounding boxes to be used for collision detection

  cleanup: (@_cleanup = @_cleanup) ->
    if @offscreen() # periodic wrapping
      if @r.x > @width then @r.x = @r.x % @width
      if @r.x < 0 then @r.x = @width + @r.x
      if @r.y > @height then @r.y = @r.y % @height 
      if @r.y < 0 then @r.y = @height + @r.y
    return    