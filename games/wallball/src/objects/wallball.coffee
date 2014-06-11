class $z.Wallball extends $z.Game
  constructor: (@config = {}) ->
    @image_list = [GameAssetsUrl + 'ball.svg', GameAssetsUrl + 'paddle.svg', GameAssetsUrl + 'wall.png']
    super
    @setup()
    @svg.style('background-color', '#000')

    @scoretxt = @g.append("text")
      .text("")
      .attr("stroke", "#222")
      .attr('stroke-width', '1px')
      .attr("fill", "#F90")
      .attr("font-size", "36px")
      .attr("x", "20")
      .attr("y", "80")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    @lives = @g.append("text")
      .text("")
      .attr("stroke", "#222")
      .attr('stroke-width', '1px')
      .attr("fill", "#F90")
      .attr("font-size", "36px")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')

    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    d3.select(window).on("keydown", @keydown) if window isnt window.top # keyboard listener
    $z.Game.message_color = '#FF4'

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
      urls: [GameAssetsUrl + 'wallball.mp3', GameAssetsUrl + 'wallball.ogg'],
      volume: 0.5,
      sprite: {
        start:[0, 899],
        miss:[899, 1231],
        ball:[2131, 110]
      }
    })
    @spawning_ball = false

  setup: ->
    @paddle = $z.Factory.spawn($z.Paddle) # paddle element i.e. under user control
    @wall   = $z.Factory.spawn($z.Wall)
    @ball   = null # no ball initially, until first spawn_ball

  keydown: =>
    switch d3.event.keyCode 
      when 39 then @paddle.nudge( 1) # right arrow
      when 37 then @paddle.nudge(-1) # left arrow
    return

  text: ->
    @scoretxt.text('SCORE: ' + $z.Gamescore.value)
    @lives.text('LIVES: ' + $z.Gamescore.lives) unless $z.Gamescore.lives < 0 # updated text to display current # of lives unless game is over/ending

  spawn_ball: ->
    return if $z.Gamescore.lives < 0 # game has ended or is loading "game over" outro sequence, so do nothing
    return if $z.Physics.off
    return if @spawning_ball # @ball?.collision
    @spawning_ball = true
    ready = @g.append("text")
      .text("GET READY")
      .attr("stroke", "none")
      .attr("fill", "#FF4")
      .attr("font-size", "36")
      .attr("x", $z.Game.width / 2 - 105)
      .attr("y", $z.Game.height / 2 + 20)
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
        @ball = $z.Factory.spawn($z.Ball)
        @ball.start()
        @spawning_ball = false
      )
    return    

  start: -> # start new game
    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", $z.Game.width / 2 - 135)
      .attr("y", 90).attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    title.text("WALLBALL")

    go = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#FF4")
      .attr("font-size", "36")
      .attr("x", $z.Game.width * 0.5 - 60)
      .attr("y", $z.Game.height / 2 + 130)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("START")
    how = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", $z.Game.width / 2 - 170)
      .attr("y", $z.Game.height - 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("Use mouse / drag to control movement")

    go.on("click", => 
      go.on("click", null) # so that clicking start more than once before it finishes fading out does not create any actions in the game
      dur = 300
      title.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      $z.Gamescore.value = 0
      super()
      $z.Game.sound.play('start')
      @wall.v.y = @wall.speed
      @spawn_ball()
      @text()
      # $z.Utils.fullscreen()
      @div.style("cursor", "none")
    )

$(document).ready(
  -> new $z.Wallball() # create the game instance
)