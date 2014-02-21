class @Force # this simple object does one job: return the value of the force f(x)
  @dr  = {x: 0, y: 0}
  @rpx = {x: 0, y: 0}
  @rmx = {x: 0, y: 0}
  @rpy = {x: 0, y: 0}
  @rmy = {x: 0, y: 0}
  @eval: (element, param, f) -> 
    switch param.type
      when 'constant'          then fx = param.fx ; fy = param.fy
      when 'friction'          then (
        fx = -param.alpha * element.v.x
        fy = -param.alpha * element.v.y
      )
      when 'spring'            then fx = -(element.r.x - param.cx) ; fy = -(element.r.y - param.cy)
      when 'charge', 'gravity' then (
        @dr.x = param.cx - element.r.x
        @dr.y = param.cy - element.r.y
        r2 = @dr.x * @dr.x + @dr.y * @dr.y
        r3 = r2 * Math.sqrt(r2)
        fx = param.q * @dr.x / r3
        fy = param.q * @dr.y / r3
      )
      when 'random' then(
        fx = 2 * (Math.random() - 0.5) * param.xScale
        fy = 2 * (Math.random() - 0.5) * param.yScale
        fx = -param.fxBound if element.r.x > param.xBound # enforce boundary
        fy = -param.fyBound if element.r.y > param.yBound # enforce boundary
        fx =  param.fxBound if element.r.x < 0 # enforce boundary
        fy =  param.fyBound if element.r.y < 0 # enforce boundary
      )
      when 'gradient' then ( # evaluate the force as the negative gradient of a scalar potential energy function V(x, y)
        rpx.x = element.r.x 
        rpx.y = element.r.y
        rpx.x += param.tol # r + dx
        rmx.x = element.r.x 
        rmx.y = element.r.y
        rmx.x -= param.tol # r - dx
        rpy.x = element.r.x
        rpy.y = element.r.y 
        rpy.y += param.tol # r + dy
        rmy.x = element.r.x
        rmy.y = element.r.y
        rmy.y -= param.tol # r - dy
        epx = param.energy(rpx) # V(r + dx)
        emx = param.energy(rmx) # V(r - dx)
        epy = param.energy(rpy) # V(r + dy)
        emy = param.energy(rmy) # V(r - dy)
        unless epx? and emx? and epy? and emy? # make sure energy is defined or else default to zero force to prevent failure
          fx = 0
          fy = 0
          break
        # compute the numerical gradient using a centered finite-difference approximation:
        fx  = -0.5 * (epx - emx) / param.tol # fx = -dV / dx 
        fy  = -0.5 * (epy - emy) / param.tol # fy = -dV / dy
      )
    f.x = fx
    f.y = fy
    f