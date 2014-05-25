class $z.Dronewar extends $z.Game

  @bg_img = GameAssetsUrl + 'space_background.jpg'

  constructor: ->
    @image_list = [GameAssetsUrl + 'space_background.jpg', GameAssetsUrl + 'drone.svg', GameAssetsUrl + 'viper.svg', GameAssetsUrl + 'fang.svg', GameAssetsUrl + 'cobra.svg']    
    super

  level: ->
    return if $z.Gamescore.lives < 0 or $z.Physics.off # do nothing if the game is over/ending
    drone_increment = 1
    @N += drone_increment unless @N >= @maxN
    @charge *= 20
    @text()
    @svg.style("cursor", "pointer")
    @element   = [] # reinitialize element list
    multiplier = 20
    offset     = 200
    $z.Drone.max_speed += 0.1
    drone_config = {energy: @N * multiplier + offset, root: @root}
    for i in [0...@N] # create element list
      newAttacker = $z.Factory.spawn($z.Drone, drone_config) unless $z.Gamescore.lives < 0 or $z.Physics.off # spawn if game is over or ending
      @element.push(newAttacker) # extend the array of all elements in this game
      @element[i].r.x = $z.Game.width  * 0.5 + (Math.random() - 0.5) * 0.5 * $z.Game.width # k   * @element[i].size * 2 + @element[i].tol - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
      @element[i].r.y = $z.Game.height * 0.1 + Math.random() * 0.1 * $z.Game.height # + j  * @element[i].size  * 2  + @element[i].tol
      @element[i].start()

    n = @element.length * 2
    dur = 300 + 200 / (100 + $z.Gamescore.value)
    return

  keydown: =>
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
        @reset() if $z.Gamescore.lives < 0
      # down arrow reverses direction of firing angle 
    return

  stop: -> # stop the game
    @root.remove()
    @lives.text("GAME OVER")
    @message('GAME OVER', => super())
    return

  start: -> # start new game
    $z.Gamescore.initialLives = 100 # for this game, use lives to mean the "energy" that the ship has left
    $z.Gamescore.lives = $z.Gamescore.initialLives
    @svg.style("background-image", 'url(' + Dronewar.bg_img + ')')
      .style('background-size', 'cover')
      .style('background-repeat', 'no-repeat')
      .style('background-position', 'top center')
    @initialN = @config.initialN || 1
    @N        = @initialN
    @maxN     = 36 # limit the max number of drones
    @root     = $z.Factory.spawn($z.Root) # root element i.e. under user control; don't need to use Factory because we never remove it
    @scoretxt = @g.append("text").text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "30")
      .attr('font-family', 'arial bold')
    @lives    = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "55")
      .attr('font-family', 'arial bold')
    @leveltxt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", "20")
      .attr("y", "80")
      .attr('font-family', 'arial bold')
    d3.select(window.top).on("keydown", @keydown) # keyboard listener
    d3.select(window).on("keydown", @keydown) unless window is window.top # keyboard listener
    # load audio:
    $z.Game.audioSwitch = true
    if $z.Game.audioSwitch
      $z.Game.sound = new Howl({
        urls: [GameAssetsUrl + 'dronewar.mp3', GameAssetsUrl + 'dronewar.ogg'],
        volume: 0.5,
        sprite: {
          music:[0, 10782],
          boom: [10782, 856],
          shot: [11639, 234]
        }
      })
    @root.draw()
    title = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "48")
      .attr("x", $z.Game.width / 2 - 150)
      .attr("y", 60)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    title.text("DRONEWAR")
    prompt = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "24")
      .attr("x", $z.Game.width / 2 - 350)
      .attr("y", $z.Game.height / 4 + 20)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
    prompt.text("SELECT SHIP:")
    root = @root # copy local reference to @root for access inside other objects without using @ 
    cobra = @g
      .append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "32")
      .attr("x", $z.Game.width / 2 - 350)
      .attr("y", $z.Game.height / 4 + 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    cobra.text("COBRA").style("fill", "#099")
    dur = 500
    cobra.on("click", -> 
      return if this.style.fill == '#000996'
      @root.ship($z.Ship.cobra()) 
      d3.select(this).transition().duration(dur).style("fill", "#099") 
      viper.style("fill", "#FFF") 
      fang.style("fill", "#FFF")
    )
    viper = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "32")
      .attr("x", $z.Game.width / 2 - 350)
      .attr("y", $z.Game.height / 4 + 200)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold').style("cursor", "pointer")
    viper.text("VIPER")
    viper.on("click", -> 
      return if this.style.fill == '#000996'
      @root.ship($z.Ship.viper()) 
      d3.select(this).transition().duration(dur).style("fill", "#099") 
      cobra.style("fill", "#FFF") 
      fang.style("fill", "#FFF")
    )
    fang = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "32")
      .attr("x", $z.Game.width / 2 - 350)
      .attr("y", $z.Game.height / 4 + 300)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    fang.text("FANG")
    fang.on("click", -> 
      return if this.style.fill == '#000996'
      @root.ship($z.Ship.fang())
      d3.select(this).transition().duration(dur).style("fill", "#099")
      viper.style("fill", "#FFF")
      cobra.style("fill", "#FFF")
    )
    go = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "#FF2")
      .attr("font-size", "42")
      .attr("x", @root.r.x - 70)
      .attr("y", @root.r.y + 100)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    go.text("START")
    go.on("click", -> 
      dur = 500
      title.transition().duration(dur).style("opacity", 0).remove()
      prompt.transition().duration(dur).style("opacity", 0).remove()
      cobra.transition().duration(dur).style("opacity", 0).remove()
      viper.transition().duration(dur).style("opacity", 0).remove()
      fang.transition().duration(dur).style("opacity", 0).remove()
      go.transition().duration(dur).style("opacity", 0).remove()
      how.transition().duration(dur).style("opacity", 0).remove()
      $z.Game.instance.root.start()
      $z.Gamescore.value = 0
      $z.Game.instance.level()
      $z.Utils.fullscreen()
    )
    how = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", "18")
      .attr("x", $z.Game.width / 2 - 350)
      .attr("y", @root.r.y + 140)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .style("cursor", "pointer")
    how.text("Use mouse / tap screen to control movement and use scrollwheel / drag for rotation")
    $z.Game.sound?.play('music') if $z.Game.musicSwitch
    super

  text: ->
    @scoretxt.text('SCORE: ' + $z.Gamescore.value)
    @leveltxt.text('LEVEL: ' + (@N - @initialN))  
    @lives.text('ENERGY: ' + $z.Gamescore.lives) 

$(document).ready(
  -> new $z.Dronewar() # create the game instance
)