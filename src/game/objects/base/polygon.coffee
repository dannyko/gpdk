class @Polygon extends Element # simplest path-based shape by default involving 3 straight line segments
  constructor: (@config = {}) ->
    super(@config)
    @type = 'Polygon'
    @path  = @config.path || @default_path() # use an equilateral triangle as the default polygonal shape
    @image = @g.append("path") # render default polygon image   
    @fill(@_fill)
    @stroke(@_stroke)
    @set_path()
  
  default_path: ->
    invsqrt3 = 1 / Math.sqrt(3) # to handle symmetry of the default equilateral triangle
    [
      {pathSegTypeAsLetter: 'M', x: -@size, y: @size * invsqrt3, react: true},
      {pathSegTypeAsLetter: 'L', x: 0,      y: -2 * @size * invsqrt3, react: true},
      {pathSegTypeAsLetter: 'L', x: @size,  y: @size * invsqrt3, react: true},
      {pathSegTypeAsLetter: 'Z'} # close the path by default
    ]

  d: -> # generate path "d" attribute
    Utils.d(@path)
    
  polygon_path: -> # assign path metadata
    for i in [0..@path.length - 2] # set edge vectors: path.r
      @path[i].r = new Vec(@path[i]).subtract(@path[(i + 1) % (@path.length - 1)]) # vector pointing to this node from the subsequent node
      @path[i].n = new Vec({x: -@path[i].r.y, y: @path[i].r.x}).normalize() # unit normal vector 
    @BB()
    return

  set_path: (@path = @path) -> # update path data and metadata
    @pathref  = @path.map((d) -> Utils.clone(d)) # original path array for reference
    @polygon_path() # set path metadata
    maxnode    = @path[0] # initialize
    @path[0].d = maxnode.x * maxnode.x + maxnode.y * maxnode.y
    maxd    = @path[0].d
    for i in [1..@path.length - 2]
      node   = @path[i]
      node.d = node.x * node.x + node.y * node.y
      maxnode = @path[i] if node.d > maxd
    @maxnode  = new Vec(maxnode) # farthest node's coordinates define the radius of the bounding circle for the entire polygon
    @size     = @maxnode.length()
    @image.attr("d", @d())
  
  BB: ->
    xmax = @path[0].x # initialize
    ymax = @path[0].y # initialize
    xmin = xmax # initialize
    ymin = ymax # initialize
    for i in [1...@path.length - 1]
      xmax = @path[i].x if @path[i].x > xmax
      xmin = @path[i].x if @path[i].x < xmin
      ymax = @path[i].y if @path[i].y > ymax
      ymin = @path[i].y if @path[i].y < ymin
    @bb_width  = xmax - xmin # splat code from http://coffeescriptcookbook.com/chapters/arrays/max-array-value
    @bb_height = ymax - ymin # splat syntax from http://coffeescriptcookbook.com/chapters/arrays/max-array-value
    super
    
  rotate_path: -> # transform original path coordinates based on the angle of rotation
    for i in [0..@path.length - 1]
      seg = @path[i]
      continue unless seg.x?
      c = Math.cos(@angle)
      s = Math.sin(@angle)
      seg.x = c * @pathref[i].x - s * @pathref[i].y
      seg.y = s * @pathref[i].x + c * @pathref[i].y
    @polygon_path() # don't call set_path here to avoid overwriting @pathref
    return