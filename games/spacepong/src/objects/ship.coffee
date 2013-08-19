class @Ship extends Polygon
  @image_url = GameAssetsUrl + "ship.png"

  set_ship = (w, h) ->
    [ 
     {pathSegTypeAsLetter: 'M', x: -w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'L', x: -w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'Z'}
     ]

  constructor: (@config = {}) ->
    @config.fill ||= 'darkblue'
    w = 20
    h = 20
    @config.path ||= set_ship(w, h)
    @config.r = new Vec({x: Game.width * 0.8 * Math.random(), y: 0.05 * Game.height * Math.random()})
    @config.tick = -> # allows the element to be part of the physics engine without moving in response to collisions; can still take part in collision events
    super(@config)
    @speed = 2 # initial ship speed
    @v.y = @speed # initial ship velocity
    @image.remove()
    @g.attr("class", "ship")
    @image = @g.append("image")
     .attr("xlink:href", Wall.image_url)
     .attr("x", -w).attr("y", -h)
     .attr("width", Game.width)
     .attr("height", Game.height)

  draw: ->
    @r.y += @dt * @v.y # update ship position with constant speed and variable direction
    if @r.y > (Game.height * 0.5 - @padding)
      on_edge   = true
      @r.y = Game.height * 0.5 - @padding
    if (@r.y + Game.height * 0.5) < @tol
      on_edge   = true
      @r.y = @tol - Game.height * 0.5
    @v.y   = -@v.y if on_edge or Math.random() < @switch_probability # randomly change direction of wall movement    
    super

  destroy_check: (element) -> # wall handles its own reactions and always overrides the default physics engine
    if element.type == 'Circle'
      return true
    else 
      console.log('bug: something other than the ball hit the wall')
      return true