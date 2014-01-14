class @Force # this simple object does one job: return the value of the force f(x)

  @eval: (element, param) -> 
    switch param.type
      when 'constant'          then fx = param.fx ; fy = param.fy
      when 'friction'          then (
        fx = -param.alpha * element.v.x
        fy = -param.alpha * element.v.y
      )
      when 'spring'            then fx = -(element.r.x - param.cx) ; fy = -(element.r.y - param.cy)
      when 'charge', 'gravity' then (
        dr = Factory.spawn(Vec, {x: param.cx - element.r.x, y: param.cy - element.r.y})
        r2 = dr.length_squared()
        r3 = r2 * Math.sqrt(r2)
        fx = param.q * dr.x / r3
        fy = param.q * dr.y / r3
        Factory.sleep(dr)
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
        rpx = Factory.spawn(Vec, element.r).add({x:  param.tol, y: 0}) # r + dx
        rmx = Factory.spawn(Vec, element.r).add({x: -param.tol, y: 0}) # r - dx
        rpy = Factory.spawn(Vec, element.r).add({y:  param.tol, x: 0}) # r + dy
        rmy = Factory.spawn(Vec, element.r).add({y: -param.tol, x: 0}) # r - dy
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
        Factory.sleep(rpx)
        Factory.sleep(rmx)
        Factory.sleep(rpy)
        Factory.sleep(rmy)
      )
    Factory.spawn(Vec, {x: fx, y: fy})