class @Wallball extends Game
  constructor: (@config = {}) ->
    super
    @setup()
    @game_over = false
    @div.style('background-color', '#111')

    @scoretxt = @g.append("text")
      .text("")
      .attr("stroke", "black")
      .attr("fill", "#F90")
      .attr("font-size", "32")
      .attr("x", "20")
      .attr("y", "80")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    @lives = @g.append("text")
      .text("")
      .attr("stroke", "black")
      .attr("fill", "#F90")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')

    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    d3.select(window).on("keydown", @keydown) if window isnt window.top # keyboard listener

  setup: ->
    @paddle = new Paddle() # paddle element i.e. under user control
    @wall   = new Wall()
    @ball   = null # no ball initially, until first spawn_ball
    @ball_check_needed = true # initially a new ball is not needed
    Game.paddle = @paddle
    Game.wall   = @wall

  keydown: () =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
      when 82 then @reset() if @game_over
    return

  spawn_ball: () ->
    return unless @ball is null or @ball?.is_destroyed
    @ball_check_needed = false # prevent @progress() from calling @spawn_ball() multiple times while first call is in progress
    @ball = null
    @svg.style("cursor", "none")
    ready = @g.append("text")
      .text("GET READY")
      .attr("stroke", "none")
      .attr("fill", "#666")
      .attr("font-size", "36")
      .attr("x", Game.width / 2 - 105)
      .attr("y", Game.height / 2 + 20)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .attr('opacity', 0)
    dur = 1000
    ready.transition()
      .duration(dur)
      .style("opacity", 1)
      .transition()
      .duration(dur)
      .style('opacity', 0)
      .remove()
      .each('end', => 
        @ball = new Ball()
        @ball_check_needed = true
      )
    return    

  start: -> # start new game
    super
    @game_over = false
    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", Game.width / 2 - 320)
      .attr("y", 90).attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    title.text("WALLBALL")

    go = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#FF2")
      .attr("font-size", "36")
      .attr("x", Game.width * 0.5 - 60)
      .attr("y", Game.height - 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("START")
    how = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", Game.width / 2 - 320)
      .attr("y", Game.height / 2 + 130)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("Use the mouse for controlling movement.")

    go.on("click", => 
      go.on("click", null) # so that clicking start more than once before it finishes fading out does not create any actions in the game
      dur = 300
      title.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      Gamescore.value = 0
      Gameprez?.start()
      @wall.v.y = @wall.speed
      d3.timer(@progress)
    )
      
  progress: =>
    @scoretxt.text('SCORE: ' + Gamescore.value)
    #@leveltxt.text('LEVEL: ' + (@N - @initialN + 1))
    if Gamescore.lives >= 0
      @lives.text('LIVES: ' + Gamescore.lives) # updated text to display current # of lives
    else 
      dur = 420
      @paddle.image.transition().duration(dur).ease('sqrt').style("opacity", 0)
      @wall.image.transition().duration(dur).ease('sqrt').style("opacity", 0)
      @stop()
      callback = => @lives.text("GAME OVER, PRESS 'R' OR CLICK/TOUCH HERE TO RESTART").on('click', @reset) ; @game_over = true ; return true
      return @end(callback)
    @spawn_ball() if @ball_check_needed 

  reset: =>
    @cleanup()
    @g.selectAll("g").remove()
    @lives.text("")
    @scoretxt.text("")
    @svg.style("cursor", "auto")
    @setup()
    Gamescore.lives = Gamescore.initialLives
    @start()
    return