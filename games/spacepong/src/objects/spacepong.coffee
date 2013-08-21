class @Spacepong extends Game
  
  @ball_count: ->
    count = 1 if Gamescore.value < 500
    count = 2 if 500 <= Gamescore.value < 5000
    count = 3 if 5000 <= Gamescore.value < 10000
    count = 4 if 10000 <= Gamescore.value < 20000
    count = 5 if Gamescore >= 20000
    count

  constructor: (@config = {}) ->
    super
    @setup()

    @scoretxt = @g.append("text")
      .text("")
      .attr("stroke", "black")
      .attr("fill", "#F90")
      .attr("font-size", "20")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial black')
    @lives = @g.append("text")
      .text("")
      .attr("stroke", "black")
      .attr("fill", "#F90")
      .attr("font-size", "20")
      .attr("x", "20")
      .attr("y", "20")
      .attr('font-family', 'arial black')

    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    d3.select(window).on("keydown", @keydown) if window isnt window.top # keyboard listener

  setup: ->
    @paddle = new Paddle() # paddle element i.e. under user control
    Game.paddle = @paddle
    @game_over = false
    @ball_check_needed = true
    @ship_check_needed = true
    @ball = []
    @ship = []

  keydown: () =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
      when 82 then @reset() if @game_over
    return

  spawn_balls: () ->
    @ball_check_needed = false
    length = @ball.length
    @ball = _.filter(@ball, (ball) -> !ball.is_destroyed)
    txt = if length > 0 and @ball.length is length then 'MULTIBALL UP' else 'GET READY'
    Integration.stop() # pause the physics engine
    ready = @g.append("text")
      .text(txt)
      .attr("stroke", "none")
      .attr("fill", "#FFF")
      .attr("font-size", "36")
      .attr("x", Game.width  / 2 - 105)
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
        @ball.push(new Ball()) while @ball.length < Spacepong.ball_count()
        @ball_check_needed = true
        Integration.start() # unpause the physics engine
      )
    return    

  spawn_ships: () ->
    @ship_check_needed = false # tells the progress timer not to spawn ships until this function is completed
    @new_ship_count = Math.max(1, 1 + Math.floor(Gamescore.value / 1000)) # (Math.random() * 4) + 1    
    @ship = [] # initialize
    @ship.push(new Ship()) while @ship.length < @new_ship_count
    @ship_check_needed = true
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
    title.text("SPACEPONG")

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
      
    go.on("click", => 
      go.on("click", null) # so that clicking start more than once before it finishes fading out does not create any actions in the game
      @svg.style("cursor", "none")
      dur = 300
      title.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      Gamescore.value = 0
      Gameprez?.start()
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
      ship.image.transition().duration(dur).ease('sqrt').style("opacity", 0) for ship in @ship
      @stop()
      callback = => @lives.text("GAME OVER, PRESS 'R' TO RESTART") ; @game_over = true ; return true
      return @end(callback)
    @spawn_balls() if (@ball.length < Spacepong.ball_count() or (_.some  @ball, (d) -> d.is_destroyed)) and @ball_check_needed
    @spawn_ships() if (_.every @ship, (d) -> d.is_destroyed) and @ship_check_needed and @ball_check_needed # only spawn ships after balls have been spawned

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