class @Wallball extends Game
  constructor: ->
    super
    @element = []
    @initialN = @config.initialN || 1
    @N        = @initialN
    @root     = new Paddle() # root element i.e. under user control  
    @scoretxt = @g.append("text").text("")
      .attr("stroke", "none").attr("fill", "white")
      .attr("font-size", "18").attr("x", "20")
      .attr("y", "40").attr('font-family', 'arial black')
    @lives    = @g.append("text")
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
    #d3.select(window).on("keydown", @keydown) # keyboard listener

  level: ->
    @svg.style("cursor", "none")
    dur = 600
    d3.select('#game_div')
      .transition(dur)
      .style("background-color", -> "hsl(" + Math.random() * 360 + ", 15%, 20%)")
    newBall = new Ball()
    @element.push(newBall) # extend the array of all elements in this game
    i = 0
    @element[i].r.x = @width  * 0.5
    @element[i].r.y = @height * 0.5
    speed = 20
    dx = @root.r.x - @element[i].r.x
    dy = @root.r.y - @element[i].r.y
    d  = Math.sqrt(dx * dx + dy * dy)
    dx /= d
    dy /= d
    @element[i].v.x = speed * dx 
    @element[i].v.y = speed * dy
    console.log(Collision.list)
    @element[i].draw()
    dur = 400
    n = @element.length * 2
    return    

  start: -> # start new game
    super
    @root.draw()
    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", @width / 2 - 320)
      .attr("y", 90).attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    title.text("WALLBALL")
    root = @root # copy local reference to @root for access inside other objects without using @ 

    go = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#FF2")
      .attr("font-size", "36")
      .attr("x", @width * 0.5 - 60)
      .attr("y", @height - 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("START")
    how = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", @width / 2 - 320)
      .attr("y", @root.r.y + 130)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
      .text("Use the mouse for controlling movement.")

    go.on("click", => 
      dur = 500
      title.transition().duration(dur).style("opacity", 0).remove()
  
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      d3.timer(@progress) # set a timer to monitor game progress
      Gamescore.value = 0
      Gameprez?.start()
    )
      
  progress: =>
    @scoretxt.text('SCORE: ' + Gamescore.value)
    #@leveltxt.text('LEVEL: ' + (@N - @initialN + 1))
    if Gamescore.lives >= 0
      @lives.text('LIVES: ' + Gamescore.lives) 
    else 
      dur = 420
      @root.image.transition().duration(dur).attr("stroke", "none").attr("fill", "#900").transition().duration(dur).ease('sqrt').style("opacity", 0)
      @lives.text('GAME OVER, PRESS "r" TO RESTART')
      @stop()
      Gameprez?.end()        
      return true
    all_destroyed = @element.every (element) -> element.destroyed
    @level() if all_destroyed
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