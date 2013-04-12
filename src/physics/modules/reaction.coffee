class @Reaction # reaction module with no class variables only class methods

  ## class methods:
  @circle_circle: (m, n, d) -> # perfectly elastic collision between perfectly circlular rigid bodies according to Newtonian dynamics
    return if m.death_check(n) || n.death_check(m)
    line    = new Vec(d)
    line.x  = line.x / d.dist # normalize to get a unit vector
    line.y  = line.y / d.dist # normalize to get a unit vector
    shift   = (d.dmin + m.tol - d.dist) * 0.5 # shift both by an equal amount adding up to satisfy tolerance
    m.r     = m.r.add(line.scale(shift)) # update position to resolve conflict
    n.r     = n.r.subtract(line.scale(shift)) # update position unless root or bullet 
    cPar    = m.v.dot(line) # projection of velocity onto the line (dot/inner-product of two vectors)
    vPar    = new Vec(line).scale(cPar) # the parallel component of the velocity to the line
    vPerp   = new Vec(m.v).subtract(vPar) # the perpendicular component of the velocity to the line 
    dPar    = n.v.dot(line) # projection of neighbor-velocity onto the line
    uPar    = new Vec(line).scale(dPar) # the parallel component of the neighbor-velocity to the line
    uPerp   = new Vec(n.v).subtract(uPar) # the perpendicular component of the neighbor-velocity to the line 
    m.v     = uPar.add(vPerp) # velocity vector for m satisfying the conditions for perfectly elastic collsions
    n.v     = vPar.add(uPerp) # velocity vector for n satisfying the conditions for perfectly elastic collsions
    return  
    
  @circle_polygon: (circle, polygon, d) ->
    return if death_check(circle, polygon)
    console.log('Reaction.circle_polygon not implemented yet')
    return