class @Ball extends Circle
  constructor: (@config = {}) ->
    @size = @config.size || 8
    super

  reaction: (n) ->  
    N    = 240 # random color parameter
    fill = "hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @flash(fill)
    
  flash: (fill) ->
    dur     = 120 # color effect transition duration parameter
    @image.transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur * 3)
      .ease('linear')
      .attr("fill", circle.fill())
  