class $z.Circle extends $z.Element
  constructor: (@config = {}) ->
    @config.size ||= 15
    super(@config)
    @type  = 'Circle'
    @BB() # reset bounding box
    @image = @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
    @overlay = @g.append("circle")
      .style('opacity', 0)
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)      
    @stroke(@_stroke)
    @fill(@_fill)

  draw: -> 
    super
    @image.attr("r", @size)

  BB: (@size = @size) -> # sets the bounding box for the circle element based on its size
    @bb_width = 2 * @size
    @bb_height = 2 * @size
    super