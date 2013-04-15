class @Polygon extends Element # simplest path-based shape by default involving 3 straight line segments
  constructor: (@config = {}) ->
    super
    @size = 15 # default size for polygon
    invsqrt3 = 1 / Math.sqrt(3) # to handle symmetry of the default equilateral triangle
    @path = # use an equilateral triangle as the default polygonal shape
      [
        {pathSegTypeAsLetter: 'M', x: -@size, y: @size * invsqrt3, react: true},
        {pathSegTypeAsLetter: 'L', x: 0, y: -2 * @size * invsqrt3, react: true},
        {pathSegTypeAsLetter: 'L', x: @size, y:  @size * invsqrt3, react: true},
        {pathSegTypeAsLetter: 'Z'} # close the path by default
      ]
    @path    = @config.path || @path
    @pathref = @path.map((d) -> _.clone(d)) # copy original path for reference
    @polygon_path() # setup path metadata
    @type    = 'Polygon'
    @maxnode = new Vec(_.max @path, (node) -> node.d = node.x * node.x + node.y * node.y) # farthest node's coordinates define the radius of the bounding circle for the entire polygon
    @radius  = @maxnode.length()
    @image   = @g.append("path") # render default polygon image 
      .attr("stroke", @_stroke)
      .attr("fill", @_fill)
      .attr("d", @d())
  
  d: ->
    Utils.d(@path)
    
  polygon_path: ->
    for i in [0..@path.length - 1]
      continue if @path[i].pathSegTypeAsLetter == 'Z' || @path[i].pathSegTypeAsLetter == 'z'
      @path[i].r = new Vec(@path[i]).subtract(@path[i + 1 % @path.length - 1]) # vector pointing to this node from the subsequent node
      @path[i].n = new Vec({x: -@path[i].y, y: @path[i].x}).normalize() # unit normal vector 