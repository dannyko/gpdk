class @Spacepong extends Game
  
  @ball_count: ->
    1 if Gamescore.value < 100
    2 if 100 <= Gamescore.value < 1000
    3 if 1000 <= Gamescore.value < 5000
    4 if 5000 <= Gamescore.value < 10000
    5 if Gamescore >= 10000

  constructor: (@config = {}) ->
    super
    @setup()
    @game_over = false

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

  keydown: () =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
      when 82 then @reset() if @game_over
    return

  level: () ->
    @new_ball_needed = false
    @new_ship_count = 1 + Math.floor(Gamescore.value / 500) # (Math.random() * 4) + 1    
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
        @ball = []
        for i in [0...Spacepong.ball_count()]
          @ball.push(new Ball())
        @ship = []
        for i in [0...new_ship_count]
          @ship.push(new Ship())
        d3.timer(@progress) # set a timer to monitor game progress
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
    title.text("SPACEPONG")

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
      @level()
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
      Gameprez?.end(Gamescore.value, callback)
      return true
    @new_ball_needed = true if @ball.length < Spacepong.ball_count()
    @level() if @new_ball_needed 
    on_edge = false # initialize
    if @ball? then return false else return true

  setup: ->
    @frame  = new Frame() # Frame({width: 800, height: 600}) # frame element to control ball 
    @paddle = new Paddle() # paddle element i.e. under user control
    @ball   = null # no ball initially, until first level
    @new_ball_needed = false # initially a new ball is not needed
    Game.paddle = @paddle
    Game.wall   = @wall

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