class @Ball extends Circle
  @image_url = GameAssetsUrl + "ball.png"

  constructor: (@config = {}) ->
    @config.size   ||= 12
    @config.fill   ||= '#FFF'
    super(@config)
    @speed_factor = 0.005
    @initial_speed = 30
    @speed = @initial_speed + Game.score * @speed_factor
    @max_speed = 200
    @image.remove()
    @g.attr("class", "ball")
    @image = @g.append("image")
      .attr("xlink:href", Ball.image_url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
    @init()

  start: ->
    super(dur = 200)

  remove: ->
    super(fadeOutSwitch = true, dur = 500)

  init: ->
    @r.x = Game.instance.paddle.r.x
    @r.y = Game.height - Game.instance.paddle.padding - Game.instance.paddle.bb_height - @config.size
    @v.x = 0 
    @v.y = -@speed

  draw: ->
    @speed = Math.min(@max_speed, @initial_speed + Game.score * @speed_factor)
    min_y = Game.instance.wall.r.y + Game.height * 0.5 + @size + @tol
    if @r.y < min_y # don't allow ball to get behind the wall
      @v.y = Math.abs(@v.y) # Make sure the ball is moving away from the wall
      @r.y = Game.instance.wall.r.y + Game.height * 0.5 + @size + @tol # resolve the collision event
      @reaction() # trigger ball reaction effect
      Game.increment_value() # increment game score value
      Gameprez?.score(Game.score)
      Game.instance.text()
    if @r.x < @tol + @size # don't allow it to go beyond left sidewall
      @r.x = @tol + @size 
      @v.x = Math.abs(@v.x)
      @reaction()
    if @r.x > Game.width - @size - @tol # don't allow ball to go beyond right sidewall
      @r.x = Game.width - @size - @tol 
      @v.x = -Math.abs(@v.x)
      @reaction()

    if @r.y >= Game.height - @size - @tol # hit the bottom of the frame, lose a life and spawn a new Ball
      if @r.y <= (Game.instance.paddle.r.y + Game.instance.paddle.height) and Math.abs(@r.x - Game.instance.paddle.r.x) <= Game.instance.paddle.size # physics engine missed the collision with the paddle
        Game.instance.paddle.remove_check(@) 
      else 
        Game.lives -= 1
        if Game.lives >= 0
          Game.instance.text()
        else 
          Game.instance.paddle.fadeOut()
          Game.instance.message('GAME OVER', -> Game.instance.stop())
        Game.sound.play('miss')
        @remove()
        Game.instance.spawn_ball()
        return
    super

  reaction: (n) ->  
    @v.normalize(@speed)
    @flash()
    Game.sound.play('ball')

  flash: ->
    dur      = 1000 / 3 # color effect transition duration parameter
    # N    = 240 # random color parameter
    fill = "#FF4" # hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .attr('opacity', 0)
      .attr('fill', fill)
      .transition()
      .duration(dur)
      .ease('poly(0.5)')
      .attr("opacity", 0.5)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("opacity", 0)
      .remove()