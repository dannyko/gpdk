class @Force
  constructor: (@params = {type: 'constant', fx: 0, fy: 0}) ->

  f: (r) -> 
    switch @params.type
      when 'constant'          then fx = @params.x ; fy = @params.y
      when 'spring'            then fx = -(r.x - @params.cx) ; fy = -(r.y - @params.cy)
      when 'charge', 'gravity' then (
        dr = new Vec({x: @params.cx - r.x, y: @params.cy - r.y})
        r2 = dr.length2()
        r3 = r2 * Math.sqrt(r2)
        fx = @params.q * dr.x / r3
        fy = @params.q * dr.y / r3
      )
      when 'random' then(
        fx = 2 * (Math.random() - 0.5) * @params.xScale
        fy = 2 * (Math.random() - 0.5) * @params.yScale
        fx = -@params.fxBound if r.x > @params.xBound # enforce boundary
        fy = -@params.fyBound if r.y > @params.yBound # enforce boundary
        fx =  @params.fxBound if r.x < 0 # enforce boundary
        fy =  @params.fyBound if r.y < 0 # enforce boundary
      )
    new Vec({x: fx, y: fy})