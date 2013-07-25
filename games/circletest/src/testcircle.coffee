class @TestCircle extends Circle
  reaction: (n) ->  
    N    = 240 # random color parameter
    fill = "hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    flash(@, fill)
    flash(n, fill)
    
  flash = (circle, fill) ->
    dur     = 120 # color effect transition duration parameter
    circle.image.transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur * 3)
      .ease('linear')
      .attr("fill", circle.fill())
      
  destroy: (remove = false) ->
    super(remove)
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
      .remove()
    @g.attr("class", "")
      .transition()
      .delay(dur)
      .duration(dur * 2)
      .ease('sqrt')
      .style("opacity", "0")
      .remove()