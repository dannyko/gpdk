class @Frame extends Polygon
  constructor: (@config = {}) ->
    @config.fill ||= 'none'
    super
    tol = 1
    w = 0.5 * (Game.width + tol)
    h = 0.5 * (Game.height + tol)
    @path = [ # frame path for border containing the ball
             {pathSegTypeAsLetter: 'M', x: -w,  y:  h, react: true},
             {pathSegTypeAsLetter: 'L', x: -w,  y: -h, react: true},
             {pathSegTypeAsLetter: 'L', x:  w,  y: -h, react: true},
             {pathSegTypeAsLetter: 'L', x:  w,  y:  h, react: true},
             {pathSegTypeAsLetter: 'Z'}
             ]
    @tick = -> # allows the element to be part of the physics engine without moving (can still take part in collision events)
    @set_path()
    @r.x = Game.width * 0.5 # centered horizontally
    @r.y = Game.height * 0.5 # centered vertically

  destroy_check: (element) ->
    if element.type == 'Circle'
      if element.r.y >= Game.height - element.size # hit the bottom of the frame, lose a life and spawn a new Ball
        Gamescore.lives -= 1
        element.destroy()
      if element.r.x <= element.size then element.v.x = Math.abs(element.v.x)
      if element.r.x >= Game.width - element.size then element.v.x = -Math.abs(element.v.x)
      Collision.resolve(@, element)
      element.reaction()
      return true
    else 
      return false