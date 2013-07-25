class @Circle extends Element
  constructor: (@config = {}) ->
    super
    @type  = 'Circle'
    @size  = 15 # default size for circle elements
    @BB() # reset bounding box
    @image = @g.append("circle")
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)

  draw: -> 
    super
    @image.attr("r", @size)

  BB: (@size = @size) -> # sets the bounding box for the circle element based on its size
    @bb_width = 2 * @size
    @bb_height = 2 * @size
    super