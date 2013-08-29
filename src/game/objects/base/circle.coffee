class @Circle extends Element
  constructor: (@config = {}) ->
    @config.size ||= 15
    super(@config)
    @type  = 'Circle'
    @BB() # reset bounding box
    @image = @g.append("circle")
    @stroke(@_stroke)
    @fill(@_fill)

  draw: -> 
    super
    @image.attr("r", @size)

  BB: (@size = @size) -> # sets the bounding box for the circle element based on its size
    @bb_width = 2 * @size
    @bb_height = 2 * @size
    super