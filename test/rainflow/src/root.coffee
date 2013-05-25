class @Root extends Circle
  constructor: (@config = {}) ->
    super
    @svg.style("cursor", "none")
    @fill('none')
    @stroke('white')
    @image.attr('opacity', 0.8).attr('stroke-width', 2)
    @svg.on("mousemove", @move) # default mouse behavior is to control the root element position
    @is_root   = true
    @tick      = -> return
    @size      = 5
    @stop()

  move: (node = @svg.node()) =>
    xy = d3.mouse(node)
    bb = document.getElementById('game_g').getBoundingClientRect()
    x_off = bb.left
    y_off = bb.bottom - bb.height
    @r.x = xy[0] - x_off
    @r.y = xy[1] - y_off
    @r.scale(1/Utils.scale)
    @draw() 