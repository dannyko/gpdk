class @Reaction # reaction module with no class variables only class methods

  ## class methods:
  @circle_circle: (m, n, d) -> # perfectly elastic collision between perfectly circlular rigid bodies according to Newtonian dynamics
    return if m.destroy_check(n) || n.destroy_check(m)
    line   = new Vec(d)
    line.x = line.x / d.dist # normalize to get a unit vector
    line.y = line.y / d.dist # normalize to get a unit vector
    overstep = Math.max(d.dmin - d.dist, 0) # account for overstep since simulated movement occurs in discrete jumps
    shift  = 0.5 * (Math.max(m.tol, n.tol) + overstep) # shift both by an equal amount adding up to satisfy tolerance while taking into account overstep
    elastic_collision(m, n, line, shift)
    console.log(m, n)
    # m.reaction(n) # should give the same result as n.reaction(m) - symmetric after destroy_check
    return  
    
  @circle_polygon: (circle, polygon, d) ->
    return if circle.destroy_check(polygon) || polygon.destroy_check(circle)
    console.log('Reaction.circle_polygon not implemented yet')
    return
    
  @polygon_polygon: (m, n, d) -> # perfectly elastic default collision type
    return if m.destroy_check(n) || n.destroy_check(m)
    # exhange the velocities parallel to the normal vector most collinear with the line joining the centroids
    mseg   = m.path[d.i]
    nseg   = n.path[d.j]
    dot1   = mseg.n.dot(d)
    dot2   = nseg.n.dot(d)
    if Math.abs(dot1) > Math.abs(dot2) 
      normal = new Vec(mseg.n).scale(dot1 / Math.abs(dot1)) 
      segj     = nseg
    else 
      normal = new Vec(nseg.n).scale(dot2 / Math.abs(dot2)) # copy of reference to line segment normal vector object defining direction of exchange of velocity components
      segj   = mseg
    overstep = 0 # normal.dot(segj.r)
    shift  = Math.max(m.tol, n.tol)
    elastic_collision(m, n, normal, shift)
    m.reaction(n) # should give the same effects as n.reaction(m) by symmetry
    return
    
  elastic_collision = (m, n, line, shift) ->
    lshift   = new Vec(line).scale(shift)
    reaction = false
    maxiter  = 8
    iter     = 1
    while Collision.check(m, n, reaction).collision or iter > maxiter
      m.r     = m.r.add(lshift) # update position to resolve conflict
      n.r     = n.r.subtract(lshift) # update position unless root or bullet 
      iter++
    cPar    = m.v.dot(line) # projection of velocity onto the line (dot/inner-product of two vectors)
    vPar    = new Vec(line).scale(cPar) # the parallel component of the velocity to the line
    vPerp   = new Vec(m.v).subtract(vPar) # the perpendicular component of the velocity to the line 
    dPar    = n.v.dot(line) # projection of neighbor-velocity onto the line
    uPar    = new Vec(line).scale(dPar) # the parallel component of the neighbor-velocity to the line
    uPerp   = new Vec(n.v).subtract(uPar) # the perpendicular component of the neighbor-velocity to the line 
    m.v     = uPar.add(vPerp) # velocity vector for m satisfying the conditions for perfectly elastic collsions
    n.v     = vPar.add(uPerp) # velocity vector for n satisfying the conditions for perfectly elastic collsions
    return