class $z.Spacepong extends $z.Game

  @bg_img = GameAssetsUrl + 'earth_background.jpg'
  
  @ball_count: ->
    count = 1 if $z.Gamescore.value < 1000
    count = 2 if 1000 <= $z.Gamescore.value < 5000
    count = 3 if 5000 <= $z.Gamescore.value < 10000
    count = 4 if 10000 <= $z.Gamescore.value
    count

  constructor: (@config = {}) ->
    @image_list = [GameAssetsUrl + 'earth_background.jpg', GameAssetsUrl + 'blue_ship.svg', GameAssetsUrl + 'green_ship.svg', GameAssetsUrl + 'red_ship.svg', GameAssetsUrl + 'paddle.svg', GameAssetsUrl + 'ball.svg']    
    super
    @initialN = 1
    @svg.style("background-image", 'url(' + $z.Spacepong.bg_img + ')')
      .style('background-size', '100%')
      .style('background-repeat', 'no-repeat')
      .style('background-position', 'top center')

    @setup()

    @scoretxt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#F90")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')

    @leveltxt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#F90")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "70")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')

    @lives = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#F90")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "100")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')

    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    d3.select(window).on("keydown", @keydown) if window isnt window.top # keyboard listener

    @svg
      .append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", $z.Game.width)
      .attr("height", $z.Game.height)
      .attr("fill", 'none')
      .attr("stroke", '#222')
      .attr("stroke-width", 2)

    $z.Game.sound = new Howl({
      urls: [GameAssetsUrl + 'spacepong.mp3', GameAssetsUrl + 'spacepong.ogg'],
      volume: 0.15,
      sprite: {
        whoosh:[0, 1060],
        boom:[1060, 557],
        loss:[1618, 486],
        miss:[2105, 934],
        bong:[3040, 192]
      }
    })

  setup: ->
    @paddle = $z.Factory.spawn($z.Paddle) # paddle element i.e. under user control
    $z.Game.paddle = @paddle
    @spawn_check_needed = true
    $z.Gamescore.lives = 2
    @level = 0 # initialize

  keydown: =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
    return
  
  spawn_ball: (txt) ->
    return if $z.Physics.off # check before spawning since game may be over
    $z.Physics.stop() # pause the movement of balls and ships
    @message(txt, @spawn_ball_callback)
    return    

  spawn_ball_callback: =>
    ball = $z.Factory.spawn($z.Ball)
    ball.start()
    $z.Physics.start() # unpause the physics engine

  spawn_ships: ->
    if $z.Gamescore.value > 0
      @new_ship_count   = Math.max(2, @initialN + Math.floor($z.Gamescore.value / 1000 + Math.random() * 2)) # (Math.random() * 4) + 1    
    else 
      @new_ship_count   = 1 # always start with one ship
    $z.Ship.speed[i]   *= 1.05 for i in [0..$z.Ship.speed.length - 1]
    Niter               = @new_ship_count
    loopCallback        = -> $z.Factory.spawn $z.Ship
    delay               = 150
    $z.Utils.delayedLoop(delay, Niter, loopCallback)
    dur = 500
    msg = if $z.Gamescore.value is 0 then 'GET READY' else 'LEVEL UP'
    @message(
      msg
      ->
      dur
    )
    ++@level
    @text()
    return

  text: ->
    @leveltxt.text('LEVEL: ' + @level)
    @scoretxt.text('SCORE: ' + $z.Gamescore.value)
    @lives.text(   'LIVES: ' + $z.Gamescore.lives) unless $z.Gamescore.lives < 0 # updated text to display current # of lives unless game is over/ending

  stop: =>
    super
    @paddle.remove()

  start: -> # start new game

    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", $z.Game.width / 2 - 320)
      .attr("y", 90).attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .text("SPACEPONG")

    how = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", $z.Game.width / 2 - 320)
      .attr("y", $z.Game.height / 2 + 130)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .text("drag, move the mouse, or use left/right arrow-keys to control the paddle")

    go = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#FF2")
      .attr("font-size", "36")
      .attr("x", $z.Game.width * 0.5 - 60)
      .attr("y", $z.Game.height - 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("START")
      
    go.on("click", => 
      go.on("click", null) # so that clicking start more than once before it finishes fading out does not create any actions in the game
      dur = 300
      title.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      $z.Gamescore.value = 0
      super()
      @text()
      @spawn_ball('GET READY')
      @spawn_ships()
      $z.Utils.fullscreen()
      @div.style("cursor", "none")
    )

$(document).ready(
  -> new $z.Spacepong() # create the game instance
)