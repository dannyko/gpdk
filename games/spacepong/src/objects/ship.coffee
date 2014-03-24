class @Ship extends Polygon
  @image_url = [GameAssetsUrl + "green_ship.png", GameAssetsUrl + "blue_ship.png", GameAssetsUrl + "red_ship.png"]
  @increment_count = [1, 2, 4]
  @speed = [1.5, 2, 3]
  @size  = [50, 45, 40] # half width/height

  ship_path = (w, h) ->
    [ 
     {pathSegTypeAsLetter: 'M', x: -w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'L', x: -w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'Z'}
     ]

  constructor: (@config = {}) ->
    super
    @name = 'Ship'
    @g.attr("class", "ship")
    @init()

  start: ->
    dur = 300 # fade-in duration
    super(dur)

  init: ->
    if Gamescore.value > 0
      maxDifficulty = Math.min(3, Math.floor(Gamescore.value / 500 + Math.random()))
    else
      maxDifficulty = 0 # always start with a green ship
    @difficulty = Math.floor(maxDifficulty * (Math.random() - 1e-6))
    @speed = Ship.speed[@difficulty] # initial ship speed
    @size = Ship.size[@difficulty] # half the sidelength of the square ship
    @image.remove() # don't display default SVG image, instead replace by custom bitmap defined below via an SVG <image> tag
    w = @size
    h = @size
    @set_path(ship_path(w, h))
    @image = @g.append("image")
     .attr("xlink:href", Ship.image_url[@difficulty])
     .attr("x", -w).attr("y", -h)
     .attr("width", 2 * w)
     .attr("height", 2 * h)
    dur = 1 # ms duration, too fast to see (i.e. "instantaneous")
    @scale(1, dur)
    @v.y = 0
    @r.x = Game.width * 0.8 * Math.random()
    @r.y = 0.05 * Game.height * Math.random()
    @r.x = 2 * @size if @r.x < 2 * @size
    @r.x = Game.width - 2 * @size if @r.x > (Game.width - 2 * @size)

  draw: ->
    if Math.abs(@v.y - Ship.speed[@difficulty]) > 0.1 * Ship.speed[@difficulty] then @v.y += .1 * (Ship.speed[@difficulty] - @v.y) # adjust wspeed towards its natural value
    @r.x = @size if @r.x < @size # keep ships in viewport
    @r.x = (Game.width - @size) if @r.x > (Game.width - @size) # keep ship in viewport
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
    if @offscreen() and Gamescore.lives >= 0 # penalize score for missing a ship unless game is over or ending
      Gamescore.decrement_value()
      Game.sound.play('loss')
      Game.instance.text()
    @scale(0.2) # shrink the image via a d3 transition
    dur = 500
    switch @difficulty # tint the hue of the flash towards the color of the ship-type (green, blue, red)
      when 0 then color = '#CFC'
      when 1 then color = '#CCF'
      when 2 then color = '#FCC'
    @flash(0.25 * dur, color)
    @g.transition().duration(dur)
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
      if Gamescore.lives >= 0 
        Gamescore.increment_value() for i in [0...Ship.increment_count[@difficulty]]
      Game.instance.text()
      Game.instance.spawn_ball('MULTIBALL UP') if old_count < Spacepong.ball_count()
      @remove()
      return true
    else # hit another ship, let physics engine handle the reaction
      return false

