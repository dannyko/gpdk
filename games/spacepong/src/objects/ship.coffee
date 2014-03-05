class @Ship extends Polygon
  @image_url = [GameAssetsUrl + "green_ship.png", GameAssetsUrl + "blue_ship.png", GameAssetsUrl + "red_ship.png"]
  @increment_count = [1, 2, 4]
  @speed = [2, 3, 4]
  @size  = [40, 35, 30]

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
    @config.r   = Factory.spawn(Vec)
    @config.r.x = Game.width * 0.8 * Math.random()
    @config.r.y = 0.05 * Game.height * Math.random()
    @config.r.x = 2 * @config.size if @config.r.x < 2 * @config.size
    @config.r.x = Game.width - 2 * @config.size if @config.r.x > (Game.width - 2 * @config.size)
    super(@config)
    @name = 'Ship'
    @image.remove() # don't display default SVG image, instead replace by custom bitmap defined below via an SVG <image> tag
    @g.attr("class", "ship")
    @speed = Ship.speed[@difficulty] # initial ship speed
    @v.y   = @speed # initial ship velocity
    @image = @g.append("image")
     .attr("xlink:href", Ship.image_url[@difficulty])
     .attr("x", -w).attr("y", -h)
     .attr("width", 2 * w)
     .attr("height", 2 * h)

  draw: ->
    if @v.y < Ship.speed[@difficulty] - 0.1 then @v.y *= 1.1
    if @v.y > Ship.speed[@difficulty] + 0.1 then @v.y *= 0.9
    @r.x = @config.size if @r.x < @config.size
    @r.x = (Game.width - @config.size) if @r.x > (Game.width - @config.size)
    super

  destroy: ->
    return if @is_destroyed # don't allow destruction twice (i.e. before transition finishes)
    @is_destroyed = true
    index = Physics.game.ship.indexOf(@)
    if index = Physics.game.ship.length - 1
      Physics.game.ship.pop()
    else
      Physics.game.ship[index] = Physics.game.ship[Physics.game.ship.length - 1]
      Physics.game.ship.pop()
    @stop() # decouple it from the physics engine to prevent any additional collision events from occurring
    (Gamescore.decrement_value() ; Game.sound.play('loss') ) if @offscreen() # penalize score for missing a ship
    fill = '#FFF' 
    dur  = 210 # color effect transition duration parameter
    @image.attr('opacity', 1)
    @image # ship destroy reaction 
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("opacity", 0)
      .each('end', =>  
        @g.remove()
      )
    Game.sound.play('boom')
    Physics.game.spawn_ships() if Physics.game.ship.every((ship) -> ship.is_destroyed)

  destroy_check: (element) -> # ship handles its own reactions and always overrides the default physics engine
    if element.name is 'Ball' # hit by ball, destroy and awaard points
      element.reaction()
      d = Collision.circle_polygon(element, @)
      console.log(d.i)
      switch d.i
        when 0 then element.v.x = -Math.abs(element.v.x)
        when 1 then element.v.y = -Math.abs(element.v.y)
        when 2 then element.v.x =  Math.abs(element.v.x)
        when 3 then element.v.y =  Math.abs(element.v.y)
      Gamescore.increment_value() for i in [0...Ship.increment_count[@difficulty]]
      Physics.game.spawn_ball('MULTIBALL UP') if Physics.game.ball.length < Spacepong.ball_count()
      @destroy()
      return true
    else # hit another ship, let physics engine handle the reaction
      return false
