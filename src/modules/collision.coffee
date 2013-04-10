class @Collision
  @check: (ei, ej) -> # check for collision between Elements i and j
    # alphabetize the object names before entering the switch block since inputs are ordered but collision types are not
    name = [ei.type, ej.type]
    sort = [ei.type, ej.type].sort() # sort names in alphabetical order
    if name[0] == sort[0] and name[1] == sort[1] # m and n are neighboring elements that need to resolve a collision event
      m = ei 
      n = ej
    else 
      m = ej
      n = ei
    switch m.type # check for combinations of the two basic collison types: circle and polygon (add rectangle later)
      # follow alphabetical order within each case to avoid repeating code i.e. collision(a, b) = collision(b, a) (unordered)
      # the last alphabetical element type gets taken care of by previous types 
      when 'Circle' then (
        switch n.type 
          when 'Circle' then (
            d = @circle_circle(m, n) 
            Reaction.circle_circle(m, n, d) if d.collision
          )
          when 'Polygon' then (
            d =  @circle_polygon(m, n) 
            Reaction.circle_polygon(m, n, d) if d.collision
          )
      )
      when 'Polygon' then (
        switch n.type 
          when 'Polygon' then (
            console.log(this, 'not implemented yet')
            # d =  @polygon_polygon(m, n) 
            # Reaction.polygon_polygon(m, n, d) if d.collision
          )
      )
    return 
      
  @circle_circle: (m, n) ->
    d           = circle_circle_dist(m, n) # object containing dx, dy, dist, dmin
    d.collision = if d.dist <= d.dmin then true else false 
    d
      
  @circle_polygon: (circle, polygon) ->
    for i in [0..polygon.path.length - 2] # SVG Path segments are defined relative to previous nodes starting from an "M"-type zeroth node 
      continue unless polygon.path[i].react # use 1st node to toggle reactions of this segment on/off
      d = circle_line_dist(circle, polygon, i) 
      continue if d.dist > circle.size # circle is too far to collide with this line segment
      d.collision = true
      break # stop for loop since we can only react with one segment per collision
    d
        
  circle_circle_dist = (m, n) -> # helper function for computing distance related quantities between two circles
    d      = {} # initialize output object containing distance related quantities
    d.dx   = m.x - n.x # horizontal displacement
    d.dy   = m.y - n.y # vertical displacement
    d.dist = Math.sqrt(d.dx * d.dx + d.dy * d.dy) # Euclidean distance i.e. Pythagorean theorem
    d.dmin = m.size + n.size # minimum allowed distance
    d

  circle_line_dist = (circle, line, i) -> # helper function for computing distance related quantities between circles and lines
    xi = line.path[i].x 
    yi = line.path[i].y
    switch line.path[i + 1].pathSegTypeAsLetter
      when 'z', 'Z' then ( # closepath segment connects last node to first node
        xj = line.path[0].x # first node x position
        yj = line.path[0].y # first node y position
      )
      else (
        xj = line.path[i + 1].x
        yj = line.path[i + 1].y
      )    
    rx = xj - xi
    ry = yj - yi
    rr = rx * rx + ry * ry 
    dx = circle.x - xi - line.x
    dy = circle.y - yi - line.y
    t  = (rx * dx + ry * dy) / rr # length of intersection along vector point from node i to node j relative to the node separation distance
    if t < 0 # distance to line was measured relative to a point outside of the line segment so compute distance to node i instead
      dist = Math.sqrt(dx * dx + dy * dy)
    else if t > 1 # ditto with respect to other node j
      dx   = circle.x - xj - line.x
      dy   = circle.y - yj - line.y
      dist = Math.sqrt(dx * dx + dy * dy)
    else # compute the distance from the point to the line
      tx   = t * rx + xi + line.x
      ty   = t * ry + yi + line.y
      dx   = circle.x - tx
      dy   = circle.y - ty
      dist = Math.sqrt(dx * dx + dy * dy)
    d  = 
      t: t
      dx: dx
      dy: dy
      r: [rx, ry]
      rr: rr
      dist: dist
