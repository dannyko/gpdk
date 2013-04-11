class @Circle extends Element
  constructor: (@config = {}) ->
    super
    @type  = 'Circle'
    @size  = 15 # default size for circle elements
    @image = @g.append("circle")
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)

  draw: -> 
    super
    @image.attr("r", @size)
    if @r.x < 0 or @r.x > @width or @r.y < 0 or @r.y > @height
      @deactivate() # bullets that go offscreen are removed automatically
      @g.remove() # clean up the DOM by removing unnecessary SVG tags for bullets that go offscreen
  
  death: ->
    @deactivate()
    dur = 100
    N = 320
    fill = "hsl(" + Math.random() * N + ", 50%, 70%)"
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
    @g.attr("class", "")
      .transition()
      .delay(dur)
      .duration(dur * 2)
      .ease('sqrt')
      .style("opacity", "0")
      .remove()  