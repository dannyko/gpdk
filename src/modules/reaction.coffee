class @Reaction # reaction module with no class variables only class methods
  
  ## class methods:
  @circle_circle: (m, n, d) -> # perfectly elastic collision between perfectly circlular rigid bodies according to Newtonian dynamics
    if m.is_root || n.is_root || m.is_bullet || n.is_bullet # check if root or bullet
      m.death()
      n.death()
      return
    line    = [d.dx, d.dy] 
    line[0] = line[0] / d.dist # normalize to get a unit vector
    line[1] = line[1] / d.dist # normalize to get a unit vector
    shift   = (d.dmin + m.tol - d.dist) * 0.5
    m.x     = m.x + shift * line[0]  # update position to resolve conflict
    m.y     = m.y + shift * line[1]  # update position to resolve conflict
    n.x     = n.x - shift * line[0]  # update position unless root or bullet 
    n.y     = n.y - shift * line[1]  # update position unless root or bullet 
    cPar    = m.u * line[0] + m.v * line[1]    # projection of velocity onto the line (dot/inner-product of two vectors)
    vPar    = [cPar * line[0], cPar * line[1]] # the parallel component of the velocity to the line
    vPerp   = [m.u - vPar[0], m.v - vPar[1]]   # the perpendicular component of the velocity to the line 
    dPar    = n.u * line[0] + n.v * line[1]    # projection of neighbor-velocity onto the line
    uPar    = [dPar * line[0], dPar * line[1]] # the parallel component of the neighbor-velocity to the line
    uPerp   = [n.u - uPar[0], n.v - uPar[1]]   # the perpendicular component of the neighbor-velocity to the line 
    m.u     = uPar[0] + vPerp[0]
    m.v     = uPar[1] + vPerp[1] # elastic collisions between circular objects exchange their velocities 
    n.u     = vPar[0] + uPerp[0] # draw neighbor velocity to avoid recomputing its projections
    n.v     = vPar[1] + uPerp[1] # draw neighbor velocity to avoid recomputing its projections
    return  
    
  @circle_polygon: (circle, polygon, d) ->
    if circle.is_root || polygon.is_root || circle.is_bullet || polygon.is_bullet # check if root or bullet
      circle.death()
      polygon.death()
      return
    console.log('Reaction.circle_triangle not implemented yet')
    return