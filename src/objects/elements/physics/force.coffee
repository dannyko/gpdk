class @Force
  constructor: (@params = {type: 'constant', fx: 0, fy: 0}) ->
    # @params = @params || {type: 'spring', k: 1, cx: 400, cy: 300} # default parameters
    # @params = @params || {type: 'random', xScale: 50, yScale: 25, xBound: 600, yBound: 600, fxBound: 100, fyBound: 100} # default parameters
  f: (x, y) -> 
    switch @params.type
      when 'constant'          then [@params.fx, @params.fy]
      when 'spring'            then [-(x - @params.cx), -(y - @params.cy)]
      when 'charge', 'gravity' then (
        dx = @params.cx - x
        dy = @params.cy - y
        r2 = dx * dx + dy * dy
        r3 = r2 * Math.sqrt(r2)
        fx = @params.q * dx / r3
        fy = @params.q * dy / r3
        [fx, fy] # attractive or repulsive depending on the sign of q the charge parameter
      )
      when 'random' then(
        fx = [2 * (Math.random() - 0.5) * @params.xScale, 2 * (Math.random() - 0.5) * @params.yScale]
        fx = -@params.fxBound if x > @params.xBound # enforce boundary
        fy = -@params.fyBound if y > @params.yBound # enforce boundary
        fx =  @params.fxBound if x < 0 # enforce boundary
        fy =  @params.fyBound if y < 0 # enforce boundary
        fx
      )
