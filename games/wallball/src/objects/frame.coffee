class Frame extends Polygon
  constructor: (@config = {}) ->
    @config.fill ||= 'none'
    super
    tol = 1
    w = 0.5 * (Game.width + tol)
    h = (Game.height + tol)
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
    @r.y = 0 # centered vertically
    @g.remove() # frame is hidden so don't render a corresponding image

  remove_check: (element) ->
    if element.type == 'Circle'
      return true
    else 
      console.log('bug: something other than the ball collided with the frame')
      return false