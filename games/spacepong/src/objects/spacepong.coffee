class @Spacepong extends Game

  @bg_img = GameAssetsUrl + 'earth_background.jpg'
  
  @ball_count: ->
    count = 1 if Gamescore.value < 1000
    count = 2 if 1000 <= Gamescore.value < 5000
    count = 3 if 5000 <= Gamescore.value < 10000
    count = 4 if 10000 <= Gamescore.value < 20000
    count = 5 if Gamescore >= 20000
    count

  constructor: (@config = {}) ->
    super
    @initialN = 4
    @svg.style("background-image", 'url(' + Spacepong.bg_img + ')').style('background-size', '100%')

    @setup()

    @scoretxt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#F90")
      .attr("font-size", "32")
      .attr("x", "20")
      .attr("y", "80")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    @lives = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#F90")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')

    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    d3.select(window).on("keydown", @keydown) if window isnt window.top # keyboard listener

    Game.sound = new Howl({
      urls: [GameAssetsUrl + 'spacepong.mp3', GameAssetsUrl + 'spacepong.ogg'],
      sprite: {
        whoosh:[0, 1060],
        boom:[1060, 557],
        loss:[1618, 486],
        miss:[2105, 934],
        bong:[3040, 192]
      }
    })

  setup: ->
    @paddle = Factory.spawn(Paddle) # paddle element i.e. under user control
    Game.paddle = @paddle
    @spawn_check_needed = true
    @ball = []
    @ship = []
    Gamescore.lives = 3

  keydown: =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
    return
  
  spawn_ball: (txt) ->
    return if Physics.off # check before spawning since game may be over
    Physics.stop() # pause the movement of balls and ships
    @message(txt, @spawn_ball_callback)
    return    

  spawn_ball_callback: =>
    ball = Factory.spawn(Ball)
    @ball.push(ball)
    ball.start()
    Physics.start() # unpause the physics engine

  spawn_ships: ->
    @new_ship_count = Math.max(1, @initialN + Math.floor(Gamescore.value / 1000)) # (Math.random() * 4) + 1    
    @ship = [] # initialize
    while @ship.length < @new_ship_count
      ship = Factory.spawn(Ship)
      @ship.push(ship) 
      ship.start()
    return

  text: ->
    @scoretxt.text('SCORE: ' + Gamescore.value)
    @lives.text('LIVES: ' + Gamescore.lives) # updated text to display current # of lives

  stop: =>
    super
    quietSwitch = true
    @ship.forEach((ship) -> ship.remove(quietSwitch)) # in case any ships were in the middle of spawning 
    @ball.forEach((ball) -> ball.remove()) # in case any balls were in the middle of spawning

  start: -> # start new game
    super

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
      Game.sound.play('whoosh')
      @text()
      @spawn_ball('GET READY')
      @spawn_ships()
    )