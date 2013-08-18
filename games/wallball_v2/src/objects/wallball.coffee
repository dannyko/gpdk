class @Wallball extends Game
  constructor: (@config = {}) ->
    super
    @frame = new Frame() # Frame({width: 800, height: 600}) # frame element to control ball 
    @root  = new Paddle() # root element i.e. under user control
    @ball  = null
    @wall  = new Wall()
    Game.paddle = @root
    Game.wall   = @wall
    @padding = 8

    @scoretxt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial black')
    @lives = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", "20")
      .attr("y", "20")
      .attr('font-family', 'arial black')
    @leveltxt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", "20")
      .attr("y", "60")
      .attr('font-family', 'arial black')
    # d3.select(window).on("keydown", @keydown) # keyboard listener

  level: () ->
    @ball = {is_destroyed: false} # placeholder
    @svg.style("cursor", "none")
    ready = @g.append("text")
      .text("GET READY")
      .attr("stroke", "none")
      .attr("fill", "yellow")
      .attr("font-size", "36")
      .attr("x", Game.width / 2 - 105)
      .attr("y", Game.height / 2 + 80)
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
      )
    return    

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
    title.text("WALLBALL")
    root = @root # copy local reference to @root for access inside other objects without using @ 

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
      dur = 300
      title.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      d3.timer(@progress) # set a timer to monitor game progress
      Gamescore.value = 0
      Gameprez?.start()
      @wall.v.y = @wall.speed
      @level()
    )
      
  progress: =>
    @scoretxt.text('SCORE: ' + Gamescore.value)
    #@leveltxt.text('LEVEL: ' + (@N - @initialN + 1))
    if Gamescore.lives >= 0
      @lives.text('LIVES: ' + Gamescore.lives) # updated text to display current # of lives
    else 
      dur = 420
      @root.image.transition().duration(dur).attr("stroke", "none").attr("fill", "#900").transition().duration(dur).ease('sqrt').style("opacity", 0)
      @lives.text('GAME OVER, PRESS "r" TO RESTART')
      @stop()
      Gameprez?.end()        
      return true
    @level() if @ball isnt null and @ball.is_destroyed
    @wall.v.y = -@wall.v.y if @ball? and (Math.random() < @wall.switch_probability or (Game.height * 0.5 - @wall.r.y) < (@wall.min_distance + @ball.size * @padding) or @wall.r.y < @wall.min_distance)
    return


  reset: =>
    @g.selectAll("g").remove()
    @lives.text("")
    @scoretxt.text("")
    @leveltxt.text("")
    @svg.style("cursor", "auto")
    @N = @initialN
    @score = 0
    @root = new Root()
    Gamescore.lives = Gamescore.initialLives
    @start()