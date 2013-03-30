class @Collision
  @check: (ei, ej) -> # check for collision between Elements i and j
    # alphabetize the object names before entering the switch block since inputs are ordered but collision types are not
    name = [ei.constructor.name, ej.constructor.name]
    sort = [ei.constructor.name, ej.constructor.name].sort() # sort names in alphabetical order
    if name[0] == sort[0] and name[1] == sort[1] # m and n are neighboring elements that need to resolve a collision event
      m = ei 
      n = ej
    else 
      m = ej
      n = ei
    switch m.constructor.name 
      # follow alphabetical order within each case to avoid repeating code i.e. collision(a, b) = collision(b, a) (unordered)
      # the last alphabetical element type gets taken care of by previous types 
      when 'Bullet' then ( # bullet type elements destroy other elements and themselves
        switch n.constructor.name 
          when 'Circle' then (
            d = @bullet_circle(m, n)
            Reaction.bullet(m, n) if d.collision # default/generic bullet reaction for now 
          )
          when 'Root' then (
            d = @bullet_root(m, n) 
            Reaction.bullet_root(m, n, d) if d.collision
          )
          when 'Polygon' then Reaction.bullet(m, n) if @bullet_triangle(m, n).collision # default/generic bullet reaction for now 
      )
      when 'Circle' then (
        switch n.constructor.name 
          when 'Circle' then (
            d = @circle_circle(m, n) 
            Reaction.circle_circle(m, n, d) if d.collision
          )
          when 'Root' then (
            d = @circle_root(m, n) 
            Reaction.circle_root(m, n, d) if d.collision
          )
          when 'Polygon' then (
            d =  @circle_triangle(m, n) 
            Reaction.circle_triangle(m, n, d) if d.collision
          )
      )
      when 'Root' then (
        switch n.constructor.name 
          when 'Polygon' then (
            d = @root_triangle(m, n)             
            Reaction.root_triangle(m, n, d) if d.collision
          )
      )
    return 
      
  @bullet_circle: (bullet, circle) ->
    d = @circle_circle(bullet, circle) # treat bullets as circles for now 
    if d.collision
      game.score += 100 
      Gameprez.score("player", score) if Gameprez?
    d
 
  @bullet_root: (bullet, root) ->
    @circle_root(bullet, root) # treat bullets as circles for now
  
  @bullet_triangle: (bullet, triangle) ->
    @circle_triangle(bullet, triangle) # treat bullets as circles for now
    
  @circle_circle: (m, n) ->
    d           = circle_circle_dist(m, n) # object containing dx, dy, dist, dmin
    d.collision = if d.dist <= d.dmin then true else false 
    d
  
  @circle_root: (circle, root) ->
    parent = Object.getPrototypeOf(Object.getPrototypeOf(root)).constructor.name
    switch parent # dynamically retrieve parent class name as string
      when 'Circle' then d = @circle_circle(circle, root) 
      when 'Polygon' then d = @circle_triangle(circle, root) 
    
  @circle_triangle: (circle, triangle) ->
    for i in [0..triangle.path.length - 2] # SVG Path segments are defined relative to previous nodes starting from an "M"-type zeroth node 
      continue unless triangle.path[i].react # use 1st node to toggle reactions of this segment on/off
      d = circle_line_dist(circle, triangle, i) 
      continue if d.dist > circle.size # circle is too far to collide with this line segment
      d.collision = true
      break # stop for loop since we can only react with one segment per collision
    d
    
  @root_triangle: (root, triangle) ->
    console.log('Collision.root_triangle() not implemented yet')
    
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
