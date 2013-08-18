class @Wall extends Polygon
  set_wall = (w, h) ->
    w -= 0.000001
    h -= 0.000001
    [ # frame path for border containing the ball
     {pathSegTypeAsLetter: 'M', x: -w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'L', x: -w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'Z'}
     ]

  constructor: (@config = {}) ->
    @config.r = new Vec({x: Game.width * 0.5, y: 0.01 * Game.height})
    @config.fill ||= 'darkblue'
    w = Game.width * 0.5
    h = @config.r.y
    @config.path ||= set_wall(w, h)
    @config.tick = -> # allows the element to be part of the physics engine without moving in response to collisions; can still take part in collision events
    super(@config)
    @switch_probability = 0.01
    @min_distance = @config.r.y
    @speed = 2 # initial wall speed

  draw: ->
    @r.y += @dt * @v.y
    @set_path(set_wall(@r.x, @r.y))
    super

  destroy_check: (element) ->
    if element.type == 'Circle'
      element.v.y = Math.abs(element.v.y) # Make sure the ball is moving away from the wall
      element.r.y = 2 * @r.y + element.size + 2 * element.tol
      element.reaction()
      Gamescore.increment_value()
      element.speed = Gamescore.increment / 5 + Gamescore.value / 500
      return true
    else 
      console.log('something other than the ball hit the wall!')
      return false