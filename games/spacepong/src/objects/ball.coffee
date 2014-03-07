class @Ball extends Circle
  @image_url = GameAssetsUrl + "ball.png"

  constructor: (@config = {}) ->
    super
    @size          = 12
    @name          = 'Ball'
    @initial_speed = 25
    @speed         = @initial_speed
    @max_speed     = @size * 10
    @image.remove()
    @g.attr("class", "ball")
    @image = @g.append("image")
      .attr("xlink:href", Ball.image_url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
    @init()

  init: ->
    @v.x = 0 
    @v.y = -@speed
    @r.x = Game.paddle.r.x + 2 * Math.random() - 1
    @r.y = Game.height - Game.paddle.padding - Game.paddle.bb_height - @config.size - @tol

  draw: ->
    if @r.y < @tol + @size # don't allow it to go beyond top sidewall
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
      if Gamescore.lives <= 0
        Gamescore.lives = -1
        Game.instance.message('GAME OVER', Game.instance.stop)
        return
      Gamescore.lives -= 1
      Game.instance.text()
      Game.sound.play('miss')
      @remove()
    super

  remove: ->
    super
    index = Game.instance.ball.indexOf(@)
    if index = Game.instance.ball.length - 1
      Game.instance.ball.pop()
    else
      Game.instance.ball[index] = Game.instance.ball[Game.instance.ball.length - 1]
      Game.instance.ball.pop()
    Game.instance.spawn_ball('GET READY') unless Gamescore.lives < 0

  reaction: (n) ->  
    @v.normalize(@speed)
    @flash()
    Game.sound.play('bong')
    super
    
  flash: ->
    # N    = 240 # random color parameter
    dur  = 200 # color effect transition duration parameter
    fill = "#FFF" # hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .attr('opacity', 0)
      .attr('fill', fill)
      .transition()
      .duration(dur)
      .ease('poly(0.5)')
      .attr("opacity", .8)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("opacity", 0)
      .remove()