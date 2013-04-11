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
      d = circle_polygon_dist(circle, polygon, i) 
      continue if d.dist > circle.size # circle is too far to collide with this polygon segment
      d.collision = true
      break # stop for loop since we can only react with one segment per collision
    d
        
  circle_circle_dist = (m, n) -> # helper function for computing distance related quantities between two circles
    d = new Vec(m.r).subtract(n.r)
    d.dist = d.length() # Euclidean distance i.e. Pythagorean theorem
    d.dmin = m.size + n.size # minimum allowed distance
    d

  circle_polygon_dist = (circle, polygon, i) -> # helper function for computing distance related quantities between circles and polygons
    ri = polygon.path[i]
    switch polygon.path[i + 1].pathSegTypeAsLetter
      when 'z', 'Z' then ( # closepath segment connects last node to first node
        rj = polygon.path[0] # first node x position
      )
      else (
        rj = polygon.path[i + 1]
      )    
    r  = new Vec(rj).subtract(ri)
    rr = r.length2() 
    dr = new Vec(circle.r).subtract(ri).subtract(polygon.r)
    t  = r.dot(dr) / rr # length of intersection along vector point from node i to node j relative to the node separation distance
    if t < 0 # distance to polygon was measured relative to a point outside of the polygon segment so compute distance to node i instead
    else if t > 1 # ditto with respect to other node j
      dr   = new Vec(circle.r).subtract(rj).subtract(polygon.r)
    else # compute the distance from the point to the polygon
      tr   = new Vec(r).scale(t).add(ri).add(polygon.r)
      dr   = new Vec(circle.r).subtract(tr)
    d  = 
      t: t
      x: dr.x
      y: dr.y
      r: [r.x, r.y]
      rr: rr
      dist: dr.length()