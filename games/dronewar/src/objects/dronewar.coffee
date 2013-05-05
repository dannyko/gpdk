class @Dronewar extends Game
  constructor: ->
    super
    @initialN = @config.initialN || 5
    @N        = @initialN
    @root     = new Root() # root element i.e. under user control  
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
    d3.select(window).on("keydown", @keydown) # keyboard listener

  level: ->
    @svg.style("cursor", "none")
    dur = 600
    d3.select('#game_div').transition(dur).style("background-color", -> "hsl(" + Math.random() * 360 + ", 15%, 20%)")
    @element = [] # reinitialize element list
    for i in [0..@N - 1] # create element list
      newAttacker = new Drone()
      newAttacker.g.attr("class", "attacker")
      @element.push(newAttacker) # extend the array of all elements in this game
    for k in [0..Math.ceil(Math.sqrt(@element.length))] # place elements on grid
      for j in [0..Math.ceil(Math.sqrt(@element.length))]
        i = k * Math.floor(Math.sqrt(@element.length)) + j
        break if i > @element.length - 1
        @element[i].r.x = @width  * 0.5 + k   * @element[i].size * 2 + @element[i].tol - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
        @element[i].r.y = @height * 0.1 + j  * @element[i].size  * 2  + @element[i].tol
        speed = 20
        dx = @root.r.x - @element[i].r.x
        dy = @root.r.y - @element[i].r.y
        d  = Math.sqrt(dx * dx + dy * dy)
        dx /= d
        dy /= d
        @element[i].v.x = 0.1 * @N * dx 
        @element[i].v.y = 0.1 * @N * dy
    element.draw() for element in @element
    @root.attacker = @element
    @root.update_attacker()
    @root.start()
    dur = 400
    n = @element.length * 2
    d3.selectAll(".attacker")
      .data(@element)
      .style("opacity", 0)
      .transition()
      .delay( (d, i) -> i / n * dur )
      .duration(dur)
      .style("opacity", 1)
      .each("end", (d, i) -> d.activate()) # start element timers
    @element.push(@root)
    @default_collision()

  keydown: () =>
    switch d3.event.keyCode 
      # when 70 then @root.fire() # f key fires bullets
      when 39 then @root.angle += @root.angleStep  ; @root.draw([@root.r.x, @root.r.y]) # right arrow changes firing angle by default
      when 37 then @root.angle -= @root.angleStep ; @root.draw([@root.r.x, @root.r.y]) # left arrow changes firing angle by default
      # when 38 then @root.fire() # up arrow fires bullet
      when 40, 38 then ( 
        @root.angle += Math.PI
        @root.draw([@root.r.x, @root.r.y]) 
      )
      when 82
        @reset() if Gamescore.lives < 0
      # down arrow reverses direction of firing angle 
    return

  stop: -> # stop the game
    super
    @root.stop()
    Gameprez.end(Gamescore.value) if Gameprez?

  start: -> # start new game
    Gameprez.start() if Gameprez? # start score tracking 
    @root.draw()
    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", @width / 2 - 320)
      .attr("y", 90)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    title.text("DRONEWAR")
    prompt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "36")
      .attr("x", @width / 2 - 320)
      .attr("y", @height / 4 + 40)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    prompt.text("SELECT SHIP")
    root = @root # copy local reference to @root for access inside other objects without using @ 
    sidewinder = @g
      .append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", @width / 2 - 320)
      .attr("y", @height / 4 + 80)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    sidewinder.text("SIDEWINDER").style("fill", "#006")
    dur = 500
    sidewinder.on("click", -> 
      return if this.style.fill == '#000066'
      root.ship(Ship.sidewinder()) 
      d3.select(this).transition().duration(dur).style("fill", "#006") 
      viper.style("fill", "#FFF") 
      fang.style("fill", "#FFF")
    )
    viper = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", @width / 2 - 320)
      .attr("y", @height / 4 + 110)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold').style("cursor", "pointer")
    viper.text("VIPER")
    viper.on("click", -> 
      return if this.style.fill == '#000066'
      root.ship(Ship.viper()) 
      d3.select(this).transition().duration(dur).style("fill", "#006") 
      sidewinder.style("fill", "#FFF") 
      fang.style("fill", "#FFF")
    )
    fang = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", @width / 2 - 320)
      .attr("y", @height / 4 + 140)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    fang.text("FANG")
    fang.on("click", -> 
      return if this.style.fill == '#000066'
      root.ship(Ship.fang())
      d3.select(this).transition().duration(dur).style("fill", "#006")
      viper.style("fill", "#FFF")
      sidewinder.style("fill", "#FFF")
    )
    go = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#FF2")
      .attr("font-size", "36")
      .attr("x", @root.r.x - 60)
      .attr("y", @root.r.y + 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    go.text("START")
    go.on("click", => 
      dur = 500
      title.transition().duration(dur).style("opacity", 0).remove()
      prompt.transition().duration(dur).style("opacity", 0).remove()
      sidewinder.transition().duration(dur).style("opacity", 0).remove()
      viper.transition().duration(dur).style("opacity", 0).remove()
      fang.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      d3.timer(@progress)
    )
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
    how.text("Use the mouse for controlling movement, scrollwheel for rotation")
    
  progress: =>  # set a timer to monitor game progress
    @scoretxt.text('SCORE: ' + Gamescore.value)
    @leveltxt.text('LEVEL: ' + (@N - @initialN + 1))
    if Gamescore.lives >= 0
      @lives.text('LIVES: ' + Gamescore.lives) 
    else 
      dur = 420
      @root.game_over()
      @lives.text("GAME OVER, PRESS 'R' TO RESTART")
      @stop()
      return true
    inactive = @element.every (element) -> 
      element.is_root or (element.react == false and element.fixed == true)
    if inactive # all inactive
      @N++
      @charge *= 10
      @level()
    return
            
  reset: =>
    @g.selectAll("g").remove()
    @lives.text("")
    @scoretxt.text("")
    @leveltxt.text("")
    @svg.style("cursor", "auto")
    @N = @initialN
    Gamescore.value = 0
    @root = new Root()
    Gamescore.lives = Gamescore.initialLives
    @start()