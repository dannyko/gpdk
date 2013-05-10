class @Circle extends Element
  constructor: (@config = {}) ->
    super
    @type  = 'Circle'
    @size  = 15 # default size for circle elements
    @BB() # set bounding box
    @image = @g.append("circle")
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)

  draw: -> 
    super
    @image.attr("r", @size)
    if @r.x < 0 or @r.x > @width or @r.y < 0 or @r.y > @height
      @stop_collision() # bullets that go offscreen are removed automatically
      @g.remove() # clean up the DOM by removing unnecessary SVG tags for bullets that go offscreen\

  BB: -> # sets the bounding box for the circle element based on its size
    @bb_width = 2 * @size
    @bb_height = 2 * @size
    super