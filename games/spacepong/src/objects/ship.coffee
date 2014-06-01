class $z.Ship extends $z.Polygon
  @image_url = [GameAssetsUrl + "green_ship.svg", GameAssetsUrl + "blue_ship.svg", GameAssetsUrl + "red_ship.svg"]
  @increment_count = [1, 2, 4]
  @speed = [.03, .04, .05]
  @size  = [40, 35, 30] # half width/height

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
    dur         = 500 # fade-in duration
    speed       = 0
    speed       = @speed
    @speed      = 0
    super(dur, (d) -> 
      d.speed      = speed
      d.collision  = true
    )

  init: ->
    if $z.Gamescore.value > 0
      maxDifficulty = Math.min(3, Math.floor($z.Gamescore.value / 500 + Math.random()))
    else
      maxDifficulty = 0 # always start with a green ship
    @difficulty = Math.floor(maxDifficulty * (Math.random() - 1e-6))
    @speed = $z.Ship.speed[@difficulty] # initial ship speed
    @size = $z.Ship.size[@difficulty] # half the sidelength of the square ship
    @image.remove() # don't display default SVG image, instead replace by custom bitmap defined below via an SVG <image> tag
    w = @size
    h = @size
    @set_path(ship_path(w, h))
    @image = @g.append("image")
     .attr("xlink:href", $z.Ship.image_url[@difficulty])
     .attr("x", -w).attr("y", -h)
     .attr("width", 2 * w)
     .attr("height", 2 * h)
    @overlay.remove() # remove default overlay
    @overlay = @g.append('circle')
      .attr('r', @size)
      .attr('x', 0)
      .attr('y', 0)
      .style('opacity', 0)
    @scale(1)
    @v.y = 0
    @r.x = $z.Game.width * 0.8 * Math.random()
    @r.y = 0.05 * $z.Game.height * Math.random()
    @r.x = 2 * @size if @r.x < 2 * @size
    @r.x = $z.Game.width - 2 * @size if @r.x > ($z.Game.width - 2 * @size)
    @start()

  draw: ->
    if @invincible
      @v.y = 0
    else
      if Math.abs(@v.y - $z.Ship.speed[@difficulty]) > 0.1 * $z.Ship.speed[@difficulty] then @v.y += .015 * ($z.Ship.speed[@difficulty] - @v.y) # adjust wspeed towards its natural value
    @v.x = 0
    @r.x = @size if @r.x < @size # keep ships in viewport
    @r.x = ($z.Game.width - @size) if @r.x > ($z.Game.width - @size) # keep ship in viewport
    super

  reaction: (n) ->
    if n? and n.constructor is Ship
      speed = Math.max(@speed, n.speed) * 4
      if n.r.y > @r.y # ship is below this ship
       n.v.y  = speed
       @v.y  *= 0.5
      else
       @v.y   = speed
       n.v.y *= 0.5
    super

  remove: (quietSwitch = $z.Gamescore.lives < 0) ->
    return if @is_removed or @is_flashing # don't allow destruction twice (i.e. before transition finishes)
    @collision  = false
    if @offscreen() and $z.Gamescore.lives >= 0 # penalize score for missing a ship unless game is over or ending
      $z.Gamescore.decrement_value()
      $z.Game.sound.play('loss')
      $z.Game.instance.text()
    dur = 500
    @scale(0.2, dur) # shrink the image via a d3 transition
    dur = 420
    switch @difficulty # tint the hue of the flash towards the color of the ship-type (green, blue, red)
      when 0 then color = '#484'
      when 1 then color = '#448'
      when 2 then color = '#844'
    @flash(dur, color, scaleFactor = 2, initialOpacity = 0.6)
    @g.transition()
      .duration(dur)
      .ease('poly(0.5)')
      .style("opacity", 0)
      .each('end', =>
        @is_removed = true
      )
    $z.Game.sound.play('boom') unless quietSwitch
    Nship       = $z.Collision.list.filter((d) -> d.constructor is Ship and d.collision).length
    $z.Game.instance.spawn_ships() if Nship is 0 and $z.Gamescore.lives >= 0

  remove_check: (element) -> # ship handles its own reactions and always overrides the default physics engine
    return if @is_removed
    if element.name is 'Ball' # hit by ball, remove and awaard points
      element.reaction()
      d = $z.Collision.circle_polygon(element, @)
      switch d.i
        when 0 then element.v.x = -Math.abs(element.v.x)
        when 1 then element.v.y = -Math.abs(element.v.y)
        when 2 then element.v.x =  Math.abs(element.v.x)
        when 3 then element.v.y =  Math.abs(element.v.y)
      old_count = $z.Spacepong.ball_count()        
      if $z.Gamescore.lives >= 0
        $z.Gamescore.increment_value() for i in [0...$z.Ship.increment_count[@difficulty]]
      $z.Game.instance.text()
      $z.Game.instance.spawn_ball('MULTIBALL UP') if old_count < $z.Spacepong.ball_count()
      @remove()
      return true
    else # hit another ship, let physics engine handle the reaction
      return false