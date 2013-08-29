class @Ball extends Circle
  @image_url = GameAssetsUrl + "ball.png"

  constructor: (@config = {}) ->
    @config.size   ||= 12
    @config.fill   ||= '#FFF'
    @config.r      ||= new Vec({x: Game.paddle.r.x + 2 * Math.random() - 1, y: Game.height - Game.paddle.bb_height - @config.size})
    super(@config)
    @name = 'Ball'
    @initial_speed = 20
    @speed = @initial_speed
    @max_speed = @size * 10
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
    if @r.y < @tol + @size # don't allow it to go beyond left sidewall
      @r.y = @tol + @size 
      @v.y = Math.abs(@v.y)
      @reaction()
    if @r.x < @tol + @size # don't allow it to go beyond left sidewall
      @r.x = @tol + @size 
      @v.x = Math.abs(@v.x)
      @reaction()
    if @r.x > Game.width - @size - @tol # don't allow ball to go beyond right sidewall
      @r.x = Game.width - @size - @tol 
      @v.x = -Math.abs(@v.x)
      @reaction()
    if @r.y >= Game.height - @size - @tol # hit the bottom of the frame, lose a life and spawn a new Ball
      if Math.abs(@r.x - Game.paddle.r.x) <= Game.paddle.size # physics engine missed the collision with the paddle
        Game.paddle.destroy_check(@) 
      else 
        Gamescore.lives -= 1
        @destroy()
        return
    super

  reaction: (n) ->  
    @v.normalize(@speed)
    @flash()
    super
    
  flash: ->
    # N    = 240 # random color parameter
    dur  = 210 # color effect transition duration parameter
    fill = "#00F" # hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .attr('opacity', 0)
      .attr('fill', fill)
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("opacity", 0.5)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("opacity", 0)
      .remove()