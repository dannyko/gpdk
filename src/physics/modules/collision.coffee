class $z.Collision
  @use_bb   = false # don't use bounding box for all collisions and reactions by default
  @list     = [] # initialize list of elements

  @update_quadtree: (force_update = false) -> 
    return unless @list.length > 0
    data = @list.filter((d) -> d.collision).map((d) -> {x: d.r.x, y: d.r.y, d: d})
    @quadtree = d3.geom.quadtree(data)

  @quadtree = @update_quadtree() # initialize

  @resolve: (m, n) -> # attempt to resolve a collision using each element's default physics behavior
    maxiter  = 32 # should not occur under normal conditions
    iter     = 1 # initialize
    reaction = false
    while $z.Collision.check(m, n, reaction) and iter <= maxiter # stop iterating after collision == false or iter > maxiter
      m.tick() # update position unless root or bullet 
      n.tick() # update position unless root or bullet 
      iter++ # increment the iteration counter

  @detect: -> # execute default collision detection using quadtree for accelerated iterations over active elements
    return unless @list.length > 0
    @update_quadtree() # update the quadtree for collision detection after all moveable elements have been moved
    length = @list.length
    i = 0
    while i < length
      d = @list[i]
      if d.collision
        size = 2 * (d.size + d.tol) # define size of selection box using the size of this element
        # define the selection box to use for searching the quadtree: 
        x0 = d.r.x - size
        x3 = d.r.x + size
        y0 = d.r.y - size
        y3 = d.r.y + size
        @quadtree.visit( (node, x1, y1, x2, y2) ->
          p = node.point 
          if p isnt null
            return false if p.is_removed # this node got cleaned up
            return false unless d isnt p.d and p.d.collision # skip this point and continue searching lower levels of the hierarchy
            if (p.x >= x0) and (p.x < x3) and (p.y >= y0) and (p.y < y3)
              $z.Collision.check(d, p.d) # check for collision and run reactions if collision occurred
          x1 >= x3 || y1 >= y3 || x2 < x0 || y2 < y0
        )
      length = @list.length
      i++

  name = [null, null] # initialize static array instance outside of class $z.function definition to reduce memory churn
  sort = [null, null] # initialize static array instance outsider of class $z.function definition to reduce memory churn

  @check: (ei, ej, reaction = true) -> # check for collision between Elements i and j
    # alphabetize the object names before entering the switch block since inputs are ordered but collision types are not
    name[0] = ei.type
    name[1] = ej.type
    sort[0] = ei.type
    sort[1] = ej.type
    sort.sort() # sort names in alphabetical order
    if name[0] == sort[0] and name[1] == sort[1] # m and n are neighboring elements that need to resolve a collision event
      m = ei 
      n = ej
    else 
      m = ej
      n = ei
    m.d.collision = false
    n.d.collision = false
    switch m.type # check for combinations of the two basic collison types: circle and polygon (add rectangle later)
      # follow alphabetical order within each case to avoid repeating code i.e. collision(a, b) = collision(b, a) (unordered)
      # the last alphabetical element type gets taken care of by previous types 
      when 'Circle' then (
        switch n.type 
          when 'Circle' then (
            d = @circle_circle(m, n) 
            reaction_type = 'circle_circle'
          )
          when 'Polygon' then (
            d =  @circle_polygon(m, n) 
            reaction_type = 'circle_polygon'
          )
      )
      when 'Polygon' then (
        switch n.type 
          when 'Polygon' then (
            d =  @polygon_polygon(m, n) 
            reaction_type = 'polygon_polygon'
          )
      )
    $z.Reaction[reaction_type](m, n, d) if d.collision and reaction # handles all cases dynamically without another switch block 
    collision = d.collision
    collision
  
  @rectangle_rectangle: (m, n) ->
    m.BB() # update bounding box 
    n.BB() # update bounding box 
    not_intersect = n.left > m.right or n.right < m.left or n.top > m.bottom or n.bottom < m.top
    not not_intersect # return true if collision occurs

  @circle_circle: (m, n) ->
    if @use_bb 
      if @rectangle_rectangle(m, n) # meant to save computation, but not implemented correctly yet (BUG)
        d           = circle_circle_dist(m, n) # object containing dx, dy, dist, dmin
        d.collision = true
      else d = collision: false
    else
      d           = circle_circle_dist(m, n) # object containing dx, dy, dist, dmin
      d.collision = if d.dist <= d.dmin then true else false 
    d
      
  @circle_polygon: (circle, polygon) ->
    if @use_bb # bounding box approximation switch
      if @rectangle_rectangle(circle, polygon)
        i   = nearest_node(polygon, circle) # polygon node closest to circle's center
        d   = circle_lineseg_dist(circle, polygon, i)
        d.i = i
        d.collision = true
      else d = collision: false
    else
      for i in [0..polygon.path.length - 2] # don't include the terminal "Z" node of the Path definition
        continue unless polygon.path[i].react # use 1st node to toggle reactions of this segment on/off
        d = circle_lineseg_dist(circle, polygon, i) 
        continue if d.dist > circle.size # circle is too far to collide with this polygon segment
        d.i = i
        d.collision = true
        break # stop for loop since we can only react with one segment per collision
    d
  
  @polygon_polygon: (m, n) -> 
    if @use_bb 
      if @rectangle_rectangle(m, n)
        d   = circle_circle_dist(m, n) # object containing dx, dy, dist, dmin
        d.i = nearest_node(m, n) # polygon node closest to the other polygon's center
        d.j = nearest_node(n, m) # node closest to the other polygon's center
        d.collision = true
      else d = collision: false
    else
      d = circle_circle_dist(m, n) # initialize output object
      d.collision = false # initialize
      if d.dist <= d.dmin # avoid calling lineseg_intersect function if intercentroid distance is greater than the sum of the radii of their bounding circles
        for i in [0..m.path.length - 2]
          for j in [0..n.path.length - 2]
            continue unless lineseg_intersect(m, n, i, j)
            d.i = i
            d.j = j
            d.collision = true
            break
          break if d.collision
    d
    
  nearest_node = (m, n) -> 
    nn  = m.path[0] # initialize
    nnd = (nn.x + m.r.x - n.r.x) * (nn.x + m.r.x - n.r.x) + (nn.y + m.r.y - n.r.y) * (nn.y + m.r.y - n.r.y)
    for i in [1..@path.length - 2]
      node = m.path[i]
      d    = (node.x + m.r.x - n.r.x) * (node.x + m.r.x - n.r.x) + (node.y + m.r.y - n.r.y) * (node.y + m.r.y - n.r.y)
      nn   = m.path[i] if d < nnd
    m.path.indexOf(nn) # node of polygon m closest to the other element n's center

  circle_circle_dist = (m, n) -> # helper function for computing distance related quantities between two circles
    d      = m.d.init(m.r).subtract(n.r) # {x: m.r.x - n.r.x, y: m.r.y - n.r.y}
    d.dist = Math.sqrt(d.x * d.x + d.y * d.y) # Euclidean distance i.e. Pythagorean theorem
    d.dmin = m.size + n.size # minimum allowed distance
    d

  circle_lineseg_dist = (circle, polygon, i) -> # helper function for computing distance related quantities between circles and line segments/polygons
    ri  = polygon.path[i]
    rj  = circle.rj.init(z_check(polygon.path, i))
    r   = circle.r_temp.init(circle.rj).subtract(ri) # {x: rj.x - ri.x, y: rj.y - ri.y}
    rr  = r.x * r.x + r.y * r.y
    dr  = circle.dr_temp.init(circle.r).subtract(ri).subtract(polygon.r) # {x: circle.r.x - ri.x - polygon.r.x, y: circle.r.y - ri.y - polygon.r.y}
    t   = (r.x * dr.x + r.y * dr.y) / rr # length of intersection along vector point from node i to node j relative to the node separation distance
    if t < 0 # distance to polygon was measured relative to a point outside of the polygon segment so compute distance to node i instead
    else if t > 1 # ditto with respect to other node j
      dr.x = circle.r.x - rj.x - polygon.r.x
      dr.y = circle.r.y - rj.y - polygon.r.y
    else # compute the distance from the point to the polygon
      dr.x = r.x * t + ri.x + polygon.r.x
      dr.y = r.y * t + ri.y + polygon.r.y
      dr.x *= -1
      dr.y *= -1
      dr.x += circle.r.x
      dr.y += circle.r.y
    d      = circle.d.init(dr)
    d.t    = t
    d.r    = [r.x, r.y]
    d.rr   = rr
    d.dist = Math.sqrt(dr.x * dr.x + dr.y * dr.y)
    d # return the d object

      
  lineseg_intersect = (m, n, i, j) -> # see http://community.topcoder.com/tc?module=Static&d1=tutorials&d2=geometry2 for details
    ri  = m.ri.init(m.path[i]) # {x: m.path[i].x, y: m.path[i].y}
    rj  = m.rj.init(z_check(m.path, i)) # {x: z.x, y: z.y}
    si  = n.ri.init(n.path[j]) # {x: n.path[j].x, y: n.path[j].y}
    sj  = n.rj.init(z_check(n.path, j)) # {x: z.x, y: z.y} 
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
    # cleanup:
    # return true or false:
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