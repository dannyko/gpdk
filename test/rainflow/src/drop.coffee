class @Drop extends Circle
  constructor: (@config = {}) ->
    super
    @dt = 1
    @size = 1
    @fill('white')
    @stroke('black')
    @image.attr('opacity', '0.8').attr('stroke-width', 0.25)
    @lifetime = Utils.timestamp()
    @max_lifetime = 2e4
    # @BB() to allow bounding boxes to be used for collision detection

  cleanup: (@_cleanup = @_cleanup) ->
    @lifetime = Utils.timestamp() - @lifetime
    @destroy() if @lifetime > @max_lifetime
    @lifetime = Utils.timestamp() - @lifetime
    if @offscreen() # periodic wrapping along horizontal axis
      if @r.x > @width then @r.x = @r.x % @width
      if @r.x < 0 then @r.x = @width + @r.x
    return    