class Wall extends Polygon
  @image_url = GameAssetsUrl + "wall.png"

  set_wall = (w, h) ->
    [ # wall path
     {pathSegTypeAsLetter: 'M', x: -w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'L', x: -w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y: -h, react: true},
     {pathSegTypeAsLetter: 'L', x:  w,  y:  h, react: true},
     {pathSegTypeAsLetter: 'Z'}
     ]

  constructor: (@config = {}) ->
    @config.fill ||= 'darkblue'
    w = Game.width * 0.5
    h = Game.height * 0.5
    @config.path ||= set_wall(w, h)
    @config.tick = -> # allows the element to be part of the physics engine without moving in response to collisions; can still take part in collision events
    super(@config)
    @r.x = Game.width * 0.5
    @r.y = -Game.height * 0.5 + 0.05 * Game.height
    @switch_probability = 0.005 # frequency of the wall's randomized direction changes
    @speed = 2 # initial wall speed
    @padding = 300
    @g.remove()
    @g = d3.select('#game_g').insert("g", ":first-child")
    @g.attr("class", "wall")
    @image = @g.append("image")
     .attr("xlink:href", Wall.image_url)
     .attr("x", -w - 1).attr("y", -h)
     .attr("width", Game.width + 2)
     .attr("height", Game.height)
    @overlay = @g.append("path")
     .attr("d", @d_attr())
     .attr("x", -w).attr("y", -h)
     .style('opacity', 0)
    @start()

  draw: ->
    @r.y += @dt * @v.y * @speed # update wall position with constant speed and variable direction
    if @r.y > (Game.height * 0.5 - @padding)
      on_edge   = true
      @r.y = Game.height * 0.5 - @padding
    if (@r.y + Game.height * 0.5) < @tol
      on_edge   = true
      @r.y = @tol - Game.height * 0.5
    @v.y = -@v.y if on_edge or Math.random() < @switch_probability # randomly change direction of wall movement    
    super

  remove: ->
    fadeOutSwitch = false
    super(fadeOutSwitch)

  remove_check: (element) -> # wall handles its own reactions and always overrides the default physics engine
    if element.type == 'Circle'
      return true
    else 
      console.log('bug: something other than the ball hit the wall')
      return true