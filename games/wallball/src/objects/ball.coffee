class $z.Ball extends $z.Circle
  @image_url = GameAssetsUrl + "ball.svg"

  constructor: (@config = {}) ->
    @config.size   ||= 12
    @config.fill   ||= '#FFF'
    super(@config)
    @speed_factor = 0.002
    @initial_speed = 5
    @speed = @initial_speed + $z.Gamescore.value * @speed_factor
    @max_speed = 200
    @image.remove()
    @g.attr("class", "ball")
    @image = @g.append("image")
      .attr("xlink:href", $z.Ball.image_url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
    @init()

  start: ->
    super(dur = 200)

  remove: ->
    super(fadeOutSwitch = true, dur = 500)

  init: ->
    @r.x = $z.Game.instance.paddle.r.x
    @r.y = $z.Game.height - $z.Game.instance.paddle.padding - $z.Game.instance.paddle.bb_height - @config.size
    @v.x = 0 
    @v.y = -@speed

  draw: ->
    min_y = $z.Game.instance.wall.r.y + $z.Game.height * 0.5 + @size + @tol
    if @r.y < min_y # don't allow ball to get behind the wall
      @v.y = Math.abs(@v.y) # Make sure the ball is moving away from the wall
      @r.y = $z.Game.instance.wall.r.y + $z.Game.height * 0.5 + @size + @tol # resolve the collision event
      @reaction() # trigger ball reaction effect
      $z.Gamescore.increment_value() # increment game score value
      @speed = Math.min(@max_speed, @initial_speed + $z.Gamescore.value * @speed_factor)
      Gameprez?.score($z.Gamescore.value)
      $z.Game.instance.text()
      $z.Game.instance.wall.speed += 1 / 16 # increment wall speed
      dur = 300
      color = '#FFF'
      scaleFactor = 1
      $z.Game.instance.wall.flash(dur, color, scaleFactor)
    if @r.x < @tol + @size # don't allow it to go beyond left sidewall
      @r.x = @tol + @size 
      @v.x = Math.abs(@v.x)
      @reaction()
    if @r.x > $z.Game.width - @size - @tol # don't allow ball to go beyond right sidewall
      @r.x = $z.Game.width - @size - @tol 
      @v.x = -Math.abs(@v.x)
      @reaction()

    if @r.y >= $z.Game.height - @size - @tol # hit the bottom of the frame, lose a life and spawn a new Ball
      if @r.y <= ($z.Game.instance.paddle.r.y + $z.Game.instance.paddle.height) and Math.abs(@r.x - $z.Game.instance.paddle.r.x) <= $z.Game.instance.paddle.size # physics engine missed the collision with the paddle
        $z.Game.instance.paddle.remove_check(@) 
      else 
        $z.Gamescore.lives -= 1 if @collision
        if $z.Gamescore.lives >= 0
          $z.Game.instance.text()
        else 
          $z.Game.instance.paddle.fadeOut()
          $z.Game.instance.message('GAME OVER', -> $z.Game.instance.stop())
        $z.Game.sound.play('miss')
        @remove()
        $z.Game.instance.spawn_ball()
        return
    super

  reaction: (n) ->  
    @v.normalize(@speed)
    @flash()
    $z.Game.sound.play('ball')

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