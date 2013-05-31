class @Utils
  @addChainedAttributeAccessor = (obj, attr) -> # modified from  http://coffeescriptcookbook.com/chapters/classes_and_objects/chaining
    obj[attr] = (newValues...) ->
      if newValues.length == 0
        obj['_' + attr]
      else
        obj['_' + attr] = newValues[0]
        obj.image.attr(attr, obj['_' + attr])
        obj        

  @timestamp = ->
    new Date().getTime() # e(new Date()).getTime()-Date.UTC(1970,0,1)

  @angle     = (a) -> 2 * Math.PI * a / 360

  @path_seg  = (p) -> # helper function for generating "d" attributes of SVG path elements
    a = p.pathSegTypeAsLetter
    switch a
      when 'M', 'm' then [a, p.x, p.y].join(" ")
      when 'L', 'l' then [a, p.x, p.y].join(" ")
      when 'A', 'a' then [a, p.r, p.r, p.rot, p.c, p.d, p.x, p.y].join(" ")
      when 'C', 'c' then [a, p.x1, p.y1, p.x2, p.y2, p.x, p.y].join(" ")
      when 'S', 's' then [a, p.x2, p.y2, p.x, p.y].join(" ")
      when 'Q', 'q' then [a, p.x1, p.y1, p.x, p.y].join(" ")
      when 'T', 't' then [a, p.x, p.y].join(" ")
      when 'Z', 'z' then a

  @d = (path) ->
    (@path_seg(p) for p in path).join(" ")      
    
  @pathTween = (d, i, a) ->
    prec = 4  # pixel spacing along path to use for control-point interpolation
    interp = (d, path) ->
      n0 = path.getTotalLength()
      p = path.cloneNode()
      p.setAttribute("d", d)
      n1 = p.getTotalLength()
      # Uniform sampling of distance based on specified precision.
      distances = [0]
      i = 0
      dt = prec / Math.max(n0, n1)
      while (i += dt) < 1
        distances.push(i)
      distances.push(1)
      # Compute point-interpolators at each distance.
      points = distances.map (t) ->
        p0 = path.getPointAtLength(t * n0)
        p1 = p.getPointAtLength(t * n1)
        d3.interpolate([p0.x, p0.y], [p1.x, p1.y])
      (t) ->
        if t < 1
          "M" + points.map((p) ->
            p(t)
          ).join("L")
        else d

    interp(d, this)

  @bilinear_interp = (matrix, x, y) -> # from http://en.wikipedia.org/wiki/Bilinear_interpolation#Algorithm
    tol = 1e-1 # for offset in case x = Math.floor(x)
    xf  = Math.floor(x)
    xc  = Math.ceil(x + tol)
    yf  = Math.floor(y)
    yc  = Math.ceil(y + tol)
    dxf = x - xf
    dxc = xc - x
    dyf = y - yf
    dyc = yc - y
    interp = matrix[yf][xf] * dxc * dyc + matrix[yf][xc] * dxf * dyc + matrix[yc][xf] * dxc * dyf + matrix[yc][xc] * dxf * dyf