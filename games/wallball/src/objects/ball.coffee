class @Ball extends Circle
  @image_url = GameAssetsUrl + "ball.png"

  constructor: (@config = {}) ->
    @config.size   ||= 12
    @config.fill   ||= '#FFF'
    @config.r      ||= new Vec({x: Game.paddle.r.x, y: Game.height - Game.paddle.padding - Game.paddle.bb_height - @config.size})
    super(@config)
    @speed_factor = 0.005
    @initial_speed = 20
    @speed = @initial_speed + Game.score * @speed_factor
    @max_speed = 100
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
    @speed = Math.min(@max_speed, @initial_speed + Game.score * @speed_factor)
    min_y = Game.wall.r.y + Game.height * 0.5 + @size + @tol
    if @r.y < min_y # don't allow ball to get behind the wall
      @v.y = Math.abs(@v.y) # Make sure the ball is moving away from the wall
      @r.y = Game.wall.r.y + Game.height * 0.5 + @size + @tol # resolve the collision event
      @reaction() # trigger ball reaction effect
      Game.increment_score() # increment game score value
      Gameprez?.score(Game.score)
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
        Game.sound.play('miss')
        @destroy()
        return
    super

  reaction: (n) ->  
    @v.normalize(@speed)
    @flash()
    Game.sound.play('ball')

  flash: ->
    dur      = 1000 / 3 # color effect transition duration parameter
    # N    = 240 # random color parameter
    fill = "#FF0" # hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .attr('opacity', 0)
      .attr('fill', fill)
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("opacity", 0.4)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("opacity", 0)
      .remove()