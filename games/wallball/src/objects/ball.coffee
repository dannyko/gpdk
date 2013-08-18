class @Ball extends Circle
  @image_url = GameAssetsUrl + "ball.png"

  constructor: (@config = {}) ->
    @config.size   ||= 8
    @config.fill   ||= '#FFF'
    @config.r      ||= new Vec({x: Game.paddle.r.x, y: Game.height - Game.paddle.bb_height - @config.size})
    super(@config)
    @speed = Gamescore.increment / 5 + Gamescore.value / 500
    @v.x   = 0 
    @v.y   = -@speed
    @image.remove()
    @g.attr("class", "ball")
    @image = @g.append("image")
      .attr("xlink:href", Ball.image_url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)

  draw: ->
    min_y = Game.wall.r.y * 2 + @size + @tol
    if @r.y < min_y # don't allow ball to get behind the wall
      @r.y = min_y 
      @v.y = Math.abs(@v.y)
      @reaction()
    super

  reaction: (n) ->  
    @v.normalize(@speed)
    # N    = 240 # random color parameter
    fill = "#FF0" # hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @flash(fill)
    
  flash: (fill) ->
    dur      = 120 # color effect transition duration parameter
    # circle = @ # copy reference to this for d3
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .attr('opacity', 0)
      .attr('fill', fill)
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("opacity", 1)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("opacity", 0)
      .remove()