class @TestPolygon extends Polygon
  reaction: (n) ->  
    N    = 240 # random color parameter
    fill = "hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    flash(@, fill)
    flash(n, fill)
    
  flash = (polygon, fill) ->
    dur = 120 # color effect transition duration parameter
    polygon.image.transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur * 3)
      .ease('linear')
      .attr("fill", polygon.fill())