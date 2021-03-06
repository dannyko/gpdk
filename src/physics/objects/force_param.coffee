class $z.ForceParam # the force config object defines the interface and provides default values for parameters used by the Force module
  constructor: (@config = {}) ->
    @type = @config.type || 'constant'
    switch @type
      when 'constant' then (
        @fx = @config.x || 0
        @fy = @config.y || 0
      )
      when 'friction' then ( 
        @alpha  = @config.alpha  || 1
        @vscale = @config.vscale || .99
        @vcut   = @config.vcut   || 1e-2
      )
      when 'spring' then (
        @cx = @config.cx || 0
        @cy = @config.cy || 0
      )
      when 'charge', 'gravity' then (
        @cx = @config.cx || 0
        @cy = @config.cy || 0
        @q  = @config.q  || 1
      )
      when 'random' then(
        @xScale  = @config.xScale || 1
        @yScale  = @config.yScale || 1
        @fxBound = @config.fxBound || 10
        @fyBound = @config.fyBound || 10
      )
      when 'gradient' then ( # evaluate the force as the negative gradient of a scalar potential energy function V(x, y)
        @tol    = @config.tol || 0.1
        @energy = @config.energy || (r) ->
      )