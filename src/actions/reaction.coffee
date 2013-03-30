class @Reaction
  @bullet: (bullet, n) ->
    bullet.deactivate()
    n.deactivate()
    bullet.g.remove() # avoids accumulating indefinite numbers of dead/used bullet elements
    dur = 100
    N = 320
    fill = "hsl(" + Math.random() * N + ", 50%, 70%)"
    n.g.append("circle").attr("r", n.size).attr("x", 0).attr("y", 0).transition().duration(dur).ease('sqrt').attr("fill", fill)
    n.g.attr("class", "").transition().delay(dur).duration(dur * 2).ease('sqrt').style("opacity", "0").remove()
    return  

  @bullet_root: (bullet, root, d) ->
    circle_root(bullet, root, d) # treat bullets as circles for now 
    return
 
  @circle_circle: (m, n, d) -> # perfectly elastic collision according to Newtonian dynamics
    line    = [d.dx, d.dy] 
    line[0] = line[0] / d.dist # normalize to get a unit vector
    line[1] = line[1] / d.dist # normalize to get a unit vector
    shift   = (d.dmin + m.tol - d.dist) * 0.5
    m.x     = m.x + shift * line[0]  # update position to resolve conflict
    m.y     = m.y + shift * line[1]  # update position to resolve conflict
    n.x     = n.x - shift * line[0]   # update position unless root
    n.y     = n.y - shift * line[1]   # update position unless root
#    line    = [m.x - n.x, m.y - n.y] 
#    length  = Math.sqrt(line[0] * line[0] + line[1] * line[1]) # length of line joining the circle centers
#    line[0] = line[0] / length # normalize to get a unit vector
#    line[1] = line[1] / length # normalize to get a unit vector
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
    #N       = 240 # random color parameter
    #dur     = 120 # color effect transition duration parameter
    #fill    = "hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    #m.image.transition().duration(dur).ease('sqrt').attr("fill", fill).transition().duration(dur * 3).ease('linear').attr("fill", m.fill()) # .each("end", () => m.force = new Force()) # default reaction
    #n.image.transition().duration(dur).ease('sqrt').attr("fill", fill).transition().duration(dur * 3).ease('linear').attr("fill", n.fill()) # .each("end", () => n.force = new Force()) # default reaction
    return  

  @circle_root: (circle, root, d) -> # root element is under mouse control and therefore cannot be moved by a collision event, so move the neighbor instead
    fill = "hsl(" + Math.random() * N + ", 80%," + "40%" + ")" # fill     = "hsl(" + Math.random() * N + ", 80%," + 0.5 * Math.sqrt(circle.u * circle.u + circle.v * circle.v) + ")"
    N       = 240 # random color parameter
    dur     = 120 # color effect transition duration parameter
    root.image.transition().duration(dur).ease('sqrt').attr("fill", fill).transition().duration(dur).ease('linear').attr("fill", root.fill()) # .each("end", () => circle.force = new Force()) # default reaction
    circle.deactivate()
    circle.g.remove()
    root.lives -= 1
#    parent = Object.getPrototypeOf(Object.getPrototypeOf(root)).constructor.name
#    switch parent # dynamically retrieve parent class name as string
#      when 'Circle' then (
#        line    = [d.dx, d.dy] # vector pointing from the circle elment to the root element
#        line[0] = line[0] / d.dist # normalize to get a unit vector
#        line[1] = line[1] / d.dist # normalize to get a unit vector
#        shift   = d.dmin + Math.max(root.tol, circle.tol) - d.dist
#      )
#      when 'Polygon' then (
#        line    = [d.dx, d.dy] # vector pointing from the circle elment to the intersection of root element
#        l       = Math.sqrt(line[0] * line[0] + line[1] * line[1])
#        line[0] = line[0] / l # (d.dist + circle.size) # normalize to get a unit vector
#        line[1] = line[1] / l # (d.dist + circle.size) # normalize to get a unit vector
#        cd      = [circle.x - root.x, circle.y - root.y]
#        dot     = line[0] * cd[0] + line[1] * cd[1] # dot product of normal to edge of closest root path and centroid difference
#        shift   = circle.size + Math.max(root.tol, circle.tol) - d.dist
#        if dot < 0 # jumped across into the interior region of the root image so negate the direction to prevent the pairwise distance from decreasing
#          shift = -shift 
#      )
#    circle.x = circle.x + shift * line[0] # update position along the line connecing circle centers according to the collision equations
#    circle.y = circle.y + shift * line[1] # update position along the line connecing circle centers according to the collision equations
#    dPar     = circle.u * line[0] + circle.v * line[1]  # projection of the circle velocity onto the line
#    uPar     = [dPar * line[0], dPar * line[1]]         # the parallel component of the neighbor-velocity to the line
#    uPerp    = [circle.u - uPar[0], circle.v - uPar[1]] # the perpendicular component of the neighbor-velocity to the line 
#    kick     = 8 # how much momentum the root element adds to the element that it collides with
#    circle.u = line[0] * kick + circle.u # update velocity along connecting line according to a constant root velocity approximation
#    circle.v = line[1] * kick + circle.v # update velocity along connecting line according to a constant root velocity approximation
#    N        = 240  
#    dur      = 300
#    fill     = "hsl(" + Math.random() * N + ", 80%," + "40%" + ")" # fill     = "hsl(" + Math.random() * N + ", 80%," + 0.5 * Math.sqrt(circle.u * circle.u + circle.v * circle.v) + ")"
#    circle.image.transition().duration(dur).ease('sqrt').attr("fill", fill).transition().duration(dur * 3).ease('linear').attr("fill", circle.fill()) # .each("end", () => circle.force = new Force()) # default reaction
#    return

  @circle_triangle: (circle, triangle, d) ->
    console.log('Reaction.circle_triangle not implemented yet')
    return  
