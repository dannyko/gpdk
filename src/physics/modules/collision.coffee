class @Collision
  @lastquad  = Utils.timestamp()
  @quadwait  = 33 + 1/3 # don't update the quadtree too often
  @list = [] # initialize list of elements

  @update_quadtree: (force_update = false) -> 
    return unless @list.length > 0
    timestamp = Utils.timestamp()
    if force_update or timestamp - @lastquad > @quadwait or not @quadtree?
      data = @list.map((d) -> {x: d.r.x, y: d.r.y, d: d})
      @quadtree = d3.geom.quadtree(data)
      @lastquad = timestamp

  @quadtree = @update_quadtree() # initialize

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
            d =  @polygon_polygon(m, n) 
            Reaction.polygon_polygon(m, n, d) if d.collision
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
      d = circle_lineseg_dist(circle, polygon, i) 
      continue if d.dist > circle.size # circle is too far to collide with this polygon segment
      d.collision = true
      break # stop for loop since we can only react with one segment per collision
    d
  
  @polygon_polygon: (m, n) -> 
    d           = new Vec(m.r).subtract(n.r)
    d.dist      = d.length()    
    d.collision = false
    d.dmin      = m.size + n.size
    if d.dist <= d.dmin # avoid calling lnieseg_intersect function if intercentroid distance is greater than the sum of the radii of their bounding circles
      for i in [0..m.path.length - 2]
        for j in [0..n.path.length - 2]
          continue unless lineseg_intersect(m, n, i, j)
          d.i = i
          d.j = j
          d.collision = true
          break
        break if d.collision
    d
    
  circle_circle_dist = (m, n) -> # helper function for computing distance related quantities between two circles
    d      = new Vec(m.r).subtract(n.r)
    d.dist = d.length() # Euclidean distance i.e. Pythagorean theorem
    d.dmin = m.size + n.size # minimum allowed distance
    d

  circle_lineseg_dist = (circle, polygon, i) -> # helper function for computing distance related quantities between circles and line segments/polygons
    ri = polygon.path[i]
    rj = z_check(polygon.path, i)
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
    d  = # literal definiton of the output object
      t: t
      x: dr.x
      y: dr.y
      r: [r.x, r.y]
      rr: rr
      dist: dr.length()
      
  lineseg_intersect = (m, n, i, j) -> # see http://community.topcoder.com/tc?module=Static&d1=tutorials&d2=geometry2 for details
    ri = new Vec(m.path[i])
    rj = new Vec(z_check(m.path, i))
    si = new Vec(n.path[j])
    sj = new Vec(z_check(n.path, j))
    A1  = rj.y - ri.y
    B1  = ri.x - rj.x
    C1  = A1 * (ri.x + m.r.x) + B1 * (ri.y + m.r.y)
    A2  = sj.y - si.y
    B2  = si.x - sj.x
    C2  = A2 * (si.x + n.r.x) + B2 * (si.y + n.r.y)
    det = A1 * B2 - A2 * B1
    return false if det == 0 # lines are parallel
    x = (B2 * C1 - B1 * C2) / det
    y = (A1 * C2 - A2 * C1) / det
    check1 = Math.min(ri.x, rj.x) - m.tol <= x - m.r.x <= Math.max(ri.x, rj.x) + m.tol
    check2 = Math.min(si.x, sj.x) - n.tol <= x - n.r.x <= Math.max(si.x, sj.x) + n.tol
    check3 = Math.min(ri.y, rj.y) - m.tol <= y - m.r.y <= Math.max(ri.y, rj.y) + m.tol
    check4 = Math.min(si.y, sj.y) - n.tol <= y - n.r.y <= Math.max(si.y, sj.y) + n.tol
    if check1 and check2 and check3 and check4
      true # intersection occurs on both line segments
    else 
      false
      
  z_check = (seg, i) ->
    switch seg[i + 1].pathSegTypeAsLetter
      when 'z', 'Z' then ( # closepath segment connects last node to first node
        seg[0] # first node x position
      )
      else (
        seg[i + 1]
      )      