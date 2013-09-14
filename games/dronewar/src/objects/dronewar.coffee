class @Dronewar extends Game

  @bg_img = GameAssetsUrl + 'space_background.jpg'

  constructor: ->
    super
    @svg.style("background-image", 'url(' + Dronewar.bg_img + ')')
    @max_score_increment = 500000 # optional max score per update for accurate Gameprez secure-tracking
    @initialN = @config.initialN || 5
    @N        = @initialN
    @root     = new Root() # root element i.e. under user control  
    @scoretxt = @g.append("text").text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", "20")
      .attr("y", "40")
      .attr('font-family', 'arial black')
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
    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    img     = new Image()
    img.src = Ship.viper().url
    img.src = Ship.sidewinder().url
    img.src = Ship.fang().url
    img.src = Drone.url

  level: ->
    @svg.style("cursor", "none")
    @element = [] # reinitialize element list
    for i in [0..@N - 1] # create element list
      newAttacker = new Drone()
      @element.push(newAttacker) # extend the array of all elements in this game
      @element[i].r.x = Game.width  * 0.5 + (Math.random() - 0.5) * 0.9 * Game.width # k   * @element[i].size * 2 + @element[i].tol - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
      @element[i].r.y = Game.height * 0.25 + (Math.random() - 0.5) * 0.9 * 0.25 * Game.height # + j  * @element[i].size  * 2  + @element[i].tol
      @element[i].draw()
    n = @element.length * 2
    @speed = .04 + Gamescore.value / 1000000
    dur = 300 + 200 / (100 + Gamescore.value)
    d3.selectAll(".drone")
      .data(@element)
      .style("opacity", 0)
      .transition()
      .delay( (d, i) -> i * dur )
      .duration(dur * 4)
      .style("opacity", 1)
      .each('end', (d) => 
        dx = @root.r.x - d.r.x
        dy = @root.r.y - d.r.y
        d1  = Math.sqrt(dx * dx + dy * dy)
        dx /= d1
        dy /= d1
        d.v.x = @N * dx * @speed
        d.v.y = @N * dy * @speed        
        d.start()
      )
    return

  update_drone: ->
    return unless @element.length > 0
    @param = 
      type: 'charge'
      cx: @root.r.x
      cy: @root.r.y
      q:  @root.charge * 500 * @speed * @speed # charge
    drone.force_param[0] = @param for drone in @element
    return

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
    callback = => @lives.text("GAME OVER, PRESS 'R' TO RESTART") ; return true
    @end(callback)
    return

  start: -> # start new game
    @root.draw()
    @root.stop()
    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", Game.width / 2 - 320)
      .attr("y", 90)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    title.text("DRONEWAR")
    prompt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "36")
      .attr("x", Game.width / 2 - 320)
      .attr("y", Game.height / 4 + 40)
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
      .attr("x", Game.width / 2 - 320)
      .attr("y", Game.height / 4 + 80)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    sidewinder.text("SIDEWINDER").style("fill", "#099")
    dur = 500
    sidewinder.on("click", -> 
      return if this.style.fill == '#000996'
      root.ship(Ship.sidewinder()) 
      d3.select(this).transition().duration(dur).style("fill", "#099") 
      viper.style("fill", "#FFF") 
      fang.style("fill", "#FFF")
    )
    viper = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", Game.width / 2 - 320)
      .attr("y", Game.height / 4 + 110)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold').style("cursor", "pointer")
    viper.text("VIPER")
    viper.on("click", -> 
      return if this.style.fill == '#000996'
      root.ship(Ship.viper()) 
      d3.select(this).transition().duration(dur).style("fill", "#099") 
      sidewinder.style("fill", "#FFF") 
      fang.style("fill", "#FFF")
    )
    fang = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", Game.width / 2 - 320)
      .attr("y", Game.height / 4 + 140)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    fang.text("FANG")
    fang.on("click", -> 
      return if this.style.fill == '#000996'
      root.ship(Ship.fang())
      d3.select(this).transition().duration(dur).style("fill", "#099")
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
      @root.start()
      d3.timer(@progress)
      Gamescore.value = 0
      Gameprez?.start(@max_score_increment) # start score tracking 
    )
    how = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", Game.width / 2 - 320)
      .attr("y", @root.r.y + 130)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    how.text("Use the mouse for controlling movement, scrollwheel for rotation")
    super
    return
    
  progress: =>  # set a timer to monitor game progress
    @update_drone()
    @scoretxt.text('SCORE: ' + Gamescore.value)
    @leveltxt.text('LEVEL: ' + (@N - @initialN + 1))
    if Gamescore.lives >= 0
      @lives.text('LIVES: ' + Gamescore.lives) 
    else 
      dur = 420
      @root.game_over(dur)
      @stop()
      return true
    all_is_destroyed = @element.every (element) -> element.is_destroyed
    if all_is_destroyed # i.e. went offscreen or hit by bullet
      @N++
      @charge *= 10
      @level()
    return
            
  reset: =>
    @cleanup()
    @g.selectAll("g").remove()
    @lives.text("")
    @scoretxt.text("")
    @leveltxt.text("")
    @svg.style("cursor", "auto")
    @N = @initialN
    @root = new Root()
    Gamescore.lives = Gamescore.initialLives
    @start()
    return