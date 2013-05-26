class @Drop extends Circle
  constructor: (@config = {}) ->
    super
    @dt = 1
    @size = .7
    @fill('white')
    @stroke('none')
    @image.attr('opacity', '0.8').attr('stroke-width', 0.25)
    @lifetime = Utils.timestamp()
    @max_lifetime = 3e4
    # @BB() to allow bounding boxes to be used for collision detection

  cleanup: (@_cleanup = @_cleanup) ->
    @lifetime = Utils.timestamp() - @lifetime
    @destroy() if @lifetime > @max_lifetime
    @lifetime = Utils.timestamp() - @lifetime
    if @offscreen() # periodic wrapping 
      if @r.x > @width then @r.x = @r.x % @width
      if @r.x < 0 then @r.x = @width + @r.x
      if @r.y < 0 then (
        @r.y = 0
        @v.y = Math.abs(@v.y)
        @r.x = (@r.x + @width * 0.5) % @width
      )
      if @r.y > @height then (
        @r.y = @height
        @v.y = -Math.abs(@v.y)
        @r.x = (@r.x + @width * 0.5) % @width
      )
    return    
