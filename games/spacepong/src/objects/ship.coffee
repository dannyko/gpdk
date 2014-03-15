class @Ship extends Polygon
  @image_url = [GameAssetsUrl + "green_ship.png", GameAssetsUrl + "blue_ship.png", GameAssetsUrl + "red_ship.png"]
  @increment_count = [1, 2, 4]
  @speed = [4, 5, 6]
  @size  = [50, 45, 40]

  set_ship = (w, h) ->
    [ 
     {pathSegTypeAsLetter: 'M', x: -w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'L', x: -w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'Z'}
     ]

  constructor: (@config = {}) ->
    @difficulty = Math.floor(3 * (Math.random() - 1e-6))
    @config.fill ||= 'darkblue'
    @config.size ||= Ship.size[@difficulty] # half the sidelength of the square ship
    w = @config.size
    h = @config.size
    @config.path ||= set_ship(w, h)
    super(@config)
    @name = 'Ship'
    @g.attr("class", "ship")
    @image.remove() # don't display default SVG image, instead replace by custom bitmap defined below via an SVG <image> tag
    @image = @g.append("image")
     .attr("xlink:href", Ship.image_url[@difficulty])
     .attr("x", -w).attr("y", -h)
     .attr("width", 2 * w)
     .attr("height", 2 * h)
    @init()

  init: ->
    @r.x = Game.width * 0.8 * Math.random()
    @r.y = 0.05 * Game.height * Math.random()
    @r.x = 2 * @config.size if @r.x < 2 * @config.size
    @r.x = Game.width - 2 * @config.size if @r.x > (Game.width - 2 * @config.size)
    @speed = Ship.speed[@difficulty] # initial ship speed
    @v.y   = @speed # initial ship velocity
    @scale(1, 1)

  draw: ->
    if @v.y < Ship.speed[@difficulty] - 0.1 then @v.y *= 1.05
    if @v.y > Ship.speed[@difficulty] + 0.1 then @v.y *= 0.95
    @r.x = @config.size if @r.x < @config.size
    @r.x = (Game.width - @config.size) if @r.x > (Game.width - @config.size)
    super

  reaction: (n) ->
    if n? and n.constructor is Ship
      if n.r.y > @r.y # ship is below this ship
       n.v.y = 3 * n.speed
      else
        @v.y = 3 * n.speed
    super

  remove: (quietSwitch = Gamescore.lives < 0) ->
    return if @is_removed # don't allow destruction twice (i.e. before transition finishes)
    @is_removed = true
    if @offscreen() # penalize score for missing a ship
     Gamescore.decrement_value()
     Game.sound.play('loss')
     Game.instance.text()
    fill = '#FFF' 
    dur  = 420 # color effect transition duration parameter
    @image.attr('opacity', 1)
    @scale(0.2)
    @g.transition()
      .duration(dur)
      .ease('poly(0.5)')
      .style("opacity", 0)

    Game.sound.play('boom') unless quietSwitch
    Nship = Collision.list.filter((d) -> d.constructor is Ship and not d.is_removed).length
    Game.instance.spawn_ships() if Nship is 0 and Gamescore.lives >= 0

  remove_check: (element) -> # ship handles its own reactions and always overrides the default physics engine
    if element.name is 'Ball' # hit by ball, remove and awaard points
      element.reaction()
      d = Collision.circle_polygon(element, @)
      switch d.i
        when 0 then element.v.x = -Math.abs(element.v.x)
        when 1 then element.v.y = -Math.abs(element.v.y)
        when 2 then element.v.x =  Math.abs(element.v.x)
        when 3 then element.v.y =  Math.abs(element.v.y)
      old_count = Spacepong.ball_count()        
      Gamescore.increment_value() for i in [0...Ship.increment_count[@difficulty]]
      Game.instance.text()
      Game.instance.spawn_ball('MULTIBALL UP') if old_count < Spacepong.ball_count()
      @remove()
      return true
    else # hit another ship, let physics engine handle the reaction
      return false

