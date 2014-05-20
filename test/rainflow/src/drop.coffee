class $z.Drop extends $z.Circle
  constructor: (@config = {}) ->
    @config.size = @config.size || .6
    super(@config)
    @fill('navy')
    @stroke('none')
    @image.attr('opacity', '0.6')
    @lifetime = $z.Utils.timestamp()
    @max_lifetime = 2e4
    @fadeIn(dur = 250)

  init: ->
    @lifetime = $z.Utils.timestamp()
    super  

  cleanup: ->
    @lifetime = $z.Utils.timestamp() - @lifetime
    @remove() if @lifetime > @max_lifetime
    @lifetime = $z.Utils.timestamp() - @lifetime
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
