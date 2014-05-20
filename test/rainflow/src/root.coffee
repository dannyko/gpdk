class $z.Root extends $z.Circle
  constructor: (@config = {}) ->
    @config.size = @config.size || 1.5
    super(@config)
    @svg.style("cursor", "none")
    @fill('none')
    @stroke('navy')
    @image.attr('opacity', 0.4).attr('stroke-width', 1)
    @svg.on("mousemove", @move) # default mouse behavior is to control the root element position
    @is_root = true
    @tick    = -> return
    @g.style('opacity', 1)

  move: (node = @svg.node()) =>
    xy = d3.mouse(node)
    @r.x  = xy[0]
    @r.y  = xy[1]
    @draw() 