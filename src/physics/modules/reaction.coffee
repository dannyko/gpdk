class @Reaction # reaction module with no class variables only class and private methods

  ## class methods:

  @circle_circle: (m, n, d) -> # perfectly elastic collision between perfectly circlular rigid bodies according to Newtonian dynamics
    return if m.remove_check(n) || n.remove_check(m)
    line     = m.line.init(d).normalize()
    overstep = Math.max(d.dmin - d.dist, 0) # account for overstep since simulated movement occurs in discrete jumps
    shift    = 0.5 * (Math.max(m.tol, n.tol) + overstep) # shift both by an equal amount adding up to satisfy tolerance while taking into account overstep
    Reaction.elastic_collision(m, n, line, shift)
    m.reaction(n) # should give the same result as n.reaction(m) - symmetric after remove_check
    return  
    
  @circle_polygon: (circle, polygon, d) ->
    return if circle.remove_check(polygon) || polygon.remove_check(circle)
    intersecting_segment = polygon.path[d.i]
    normal = intersecting_segment.n
    shift = 0.5 * Math.max(circle.tol, polygon.tol)
    Reaction.elastic_collision(circle, polygon, normal, shift)
    console.log('circle_polygon', circle, polygon)
    return
    
  @polygon_polygon: (m, n, d) -> # perfectly elastic default collision type
    return if m.remove_check(n) || n.remove_check(m)
    # exhange the velocities parallel to the normal vector most collinear with the line joining the centroids
    mseg   = m.path[d.i]
    nseg   = n.path[d.j]
    dot_a   = mseg.n.dot(d)
    dot_b   = nseg.n.dot(d)
    if Math.abs(dot_a) > Math.abs(dot_b) 
      normal = m.normal.init(mseg.n).scale(dot_a / Math.abs(dot_a)) 
      segj   = nseg
    else 
      normal = m.normal.init(nseg.n).scale(dot_b / Math.abs(dot_b)) # copy of reference to line segment normal vector object defining direction of exchange of velocity components
      segj   = mseg
    shift  = 0.5 * Math.max(m.tol, n.tol)
    Reaction.elastic_collision(m, n, normal, shift)
    m.reaction(n) # should give the same effects as n.reaction(m) by symmetry -- see Element abstract superclass
    return
    
  @elastic_collision: (m, n, line, shift) ->
    lshift = m.lshift.init(line).scale(shift) # the amount to shift the elements by for each iteration as a 2D Vector
    maxiter  = 32 # should not occur under normal conditions
    iter     = 1 # initialize
    reaction = false # input for collision check to prevent reaction being called while the while loop executes
    while Collision.check(m, n, reaction) and iter <= maxiter # stop iterating after collision == false or iter > maxiter
      m.r     = m.r.add(lshift) # update position to resolve conflict
      n.r     = n.r.subtract(lshift) # update position unless root or bullet 
      iter++ # increment the iteration counter
    cPar    = m.v.dot(line) # projection of velocity onto the line (dot/inner-product of two vectors)
    vPar    = m.vPar.init(line).scale(cPar) # the parallel component of the velocity to the line
    vPerp   = m.vPerp.init(m.v).subtract(vPar) # the perpendicular component of the velocity to the line 
    dPar    = n.v.dot(line) # projection of neighbor-velocity onto the line
    uPar    = m.uPar.init(line).scale(dPar) # the parallel component of the neighbor-velocity to the line
    uPerp   = m.uPerp.init(n.v).subtract(uPar) # the perpendicular component of the neighbor-velocity to the line 
    uPar.add(vPerp) # velocity vector for m satisfying the conditions for perfectly elastic collsions
    vPar.add(uPerp) # velocity vector for n satisfying the conditions for perfectly elastic collsions
    # update element velocities explicitly, without copying any object references, to avoid bugs/memory leaks/other issues
    m.v.x = uPar.x
    m.v.y = uPar.y
    n.v.x = vPar.x
    n.v.y = vPar.y
    return