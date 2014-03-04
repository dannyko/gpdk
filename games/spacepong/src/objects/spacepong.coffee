class @Spacepong extends Game

  @bg_img = GameAssetsUrl + 'earth_background.jpg'
  
  @ball_count: ->
    count = 1 if Gamescore.value < 500
    count = 2 if 500 <= Gamescore.value < 5000
    count = 3 if 5000 <= Gamescore.value < 10000
    count = 4 if 10000 <= Gamescore.value < 20000
    count = 5 if Gamescore >= 20000
    count

  constructor: (@config = {}) ->
    super
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
    @game_over = false
    @spawn_check_needed = true
    @ball = []
    @ship = []

  keydown: =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
      when 82 then @reset() if @game_over
    return

  spawn_check: ->
    @spawn_check_needed = false # to prevent it from being called twice by @progress()
    length = @ball.length
    unless length > 0 and @ball.every((ball) -> !ball.is_destroyed) # check if any balls have been destroyed
      @ball = @ball.filter((ball) -> !ball.is_destroyed)
      txt = if length > 0 and @ball.length is length then ( Game.sound.play('whoosh') ; 'MULTIBALL UP' ) else ( 'GET READY' )
      Physics.stop() # pause the physics engine
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
          @ball.push(Factory.spawn(Ball)) while @ball.length < Spacepong.ball_count()
          Physics.start(@) # unpause the physics engine
          @spawn_ships()
        )
    else
      @spawn_ships()    
    return    

  spawn_ships: ->
    @new_ship_count = Math.max(1, 1 + Math.floor(Gamescore.value / 1000)) # (Math.random() * 4) + 1    
    console.log(@ship)
    if @ship.every((ship) -> ship.is_destroyed)
      @ship = [] # initialize
      while @ship.length < @new_ship_count
        ship = Factory.spawn(Ship)
        @ship.push(ship) 
        ship.start()
    @spawn_check_needed = true # tells @progress() to do another check
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
      Game.sound.play('whoosh')
      Physics.callbacks.push(@progress)
    )
      
  progress: =>
    console.log('spacepong.progress: ', @spawn_check_needed)
    @scoretxt.text('SCORE: ' + Gamescore.value)
    #@leveltxt.text('LEVEL: ' + (@N - @initialN + 1))
    if Gamescore.lives >= 0
      @lives.text('LIVES: ' + Gamescore.lives) # updated text to display current # of lives
    else 
      dur = 420
      @paddle.image.transition().duration(dur).ease('sqrt').style("opacity", 0)
      ship.image.transition().duration(dur).ease('sqrt').style("opacity", 0) for ship in @ship
      @stop()
      callback = => @lives.text("GAME OVER, PRESS 'R' OR CLICK/TOUCH HERE TO RESTART").on('click', @reset) ; @game_over = true ; return true
      # return @end(callback)
    @spawn_check() if @spawn_check_needed # (@ball.length < Spacepong.ball_count() or (@ball.some (d) -> d.is_destroyed)) and @ball_check_needed
    return
    # @spawn_ships() if (@ship.every (d) -> d.is_destroyed) and @ship_check_needed and @ball_check_needed # only spawn ships after balls have been spawned

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