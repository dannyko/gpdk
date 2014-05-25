class $z.Ball extends $z.Circle
  @image_url = GameAssetsUrl + "ball.svg"

  constructor: (@config = {}) ->
    super
    @is_busy       = false # to prevent overlapping 'bong' sound effects from firing
    @size          = 10
    @name          = 'Ball'
    @initial_speed = 8
    @speed         = @initial_speed
    @max_speed     = @size * 10
    @image.remove()
    @g.attr("class", "ball")
    @image = @g.append("image")
      .attr("xlink:href", $z.Ball.image_url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
    @init()

  init: ->
    @v.x = 0 
    @v.y = -@speed
    @r.x = $z.Game.paddle.r.x + 2 * Math.random() - 1
    @r.y = $z.Game.height - $z.Game.paddle.padding - $z.Game.paddle.bb_height - @config.size - @tol
    @flashing = false

  draw: ->
    return if $z.Gamescore.lives < 0 # do nothing if game is over / ending
    if @r.y < @tol + @size # don't allow it to go beyond top sidewall
      @r.y = @tol + @size 
      @v.y = Math.abs(@v.y)
      @reaction()
    if @r.x < @tol + @size # don't allow it to go beyond left sidewall
      @r.x = @tol + @size 
      @v.x = Math.abs(@v.x)
      @reaction()
    if @r.x > $z.Game.width - @size - @tol # don't allow ball to go beyond right sidewall
      @r.x = $z.Game.width - @size - @tol 
      @v.x = -Math.abs(@v.x)
      @reaction()
    if @r.y >= $z.Game.height - @size - @tol # hit the bottom of the frame, lose a life and spawn a new Ball
      if $z.Gamescore.lives <= 0
        $z.Gamescore.lives = -1
        $z.Game.instance.paddle.fadeOut()
        $z.Game.instance.message('GAME OVER', -> $z.Game.instance.stop())
        return
      $z.Gamescore.lives -= 1
      $z.Game.instance.text()
      $z.Game.sound.play('miss')
      @remove()
    super

  remove: ->
    dur = 500
    fadeOutSwitch = true
    super(fadeOutSwitch, dur)
    $z.Game.instance.spawn_ball('GET READY') unless $z.Gamescore.lives < 0
    return

  reaction: (n) ->  
    return if @is_busy
    @is_busy = true
    @v.normalize(@speed)
    @flash()
    $z.Game.sound.play('bong') unless @is_busy
    super
    
  flash: ->
    return if @flashing
    @flashing = true
    # N    = 240 # random color parameter
    dur  = 200 # color effect transition duration parameter
    fill = "#FFF" # hsl(" + Math.random() * N + ",80%," + "40%" + ")"
    @g.append("circle")
      .attr("r", @size*1.05)
      .attr("x", 0)
      .attr("y", 0)
      .attr('opacity', 0)
      .attr('fill', fill)
      .transition()
      .duration(dur)
      .ease('poly(0.5)')
      .attr("opacity", .5)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("opacity", 0)
      .each('end', (d) -> d.flashing = false)
      .remove()