class @Root extends Circle
  constructor: (@config = {}) ->
    super
    @svg.style("cursor", "none")
    @fill('none')
    @stroke('navy')
    @image.attr('opacity', 0.4).attr('stroke-width', 1.5)
    @svg.on("mousemove", @move) # default mouse behavior is to control the root element position
    @is_root = true
    @tick    = -> return
    @size    = 2.5
    @stop()

  move: (node = @svg.node()) =>
    xy    = d3.mouse(node)
    bb    = document.getElementById('game_g').getBoundingClientRect()
    x_off = bb.left
    y_off = bb.bottom - bb.height
    @r.x  = xy[0] - x_off
    @r.y  = xy[1] - y_off
    @r.scale(1 / Utils.scale)
    @draw() 