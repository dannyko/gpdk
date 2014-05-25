class $z.Wall extends $z.Polygon
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
    w = $z.Game.width * 0.5
    h = $z.Game.height * 0.5
    @config.path ||= set_wall(w, h)
    @config.tick = -> # allows the element to be part of the physics engine without moving in response to collisions; can still take part in collision events
    super(@config)
    @r.x     =  w
    @r.y     = -h + 0.05 * $z.Game.height
    @switch_probability = 0.005 # frequency of the wall's randomized direction changes
    @speed   = 2 # initial wall speed
    @padding = 300
    @clip = @svg
      .append 'clipPath'
      .attr 'id', 'cut-top'
      .append 'rect'
      .attr 'x', -w
      .attr 'y', -@r.y - @padding
      .attr 'width', $z.Game.width
      .attr 'height', $z.Game.height
    @g.remove()
    @g = d3.select('#game_g').insert("g", ":first-child")
    @g.attr("class", "wall").attr 'clip-path', 'url(#cut-top)'
    @image = @g.append("image")
     .attr("xlink:href", $z.Wall.image_url)
     .attr("x", -w).attr("y", -h)
     .attr("width", $z.Game.width)
     .attr("height", $z.Game.height)
    @overlay = @g.append("path")
     .attr("d", @d_attr())
     .attr("x", -w).attr("y", -h)
     .style('opacity', 0)
    @start()

  draw: ->
    @r.y += @dt * @v.y * @speed # update wall position with constant speed and variable direction
    if @r.y > ($z.Game.height * 0.5 - @padding)
      on_edge   = true
      @r.y = $z.Game.height * 0.5 - @padding
    if (@r.y + $z.Game.height * 0.5) < @tol
      on_edge   = true
      @r.y = @tol - $z.Game.height * 0.5
    @v.y = -@v.y if on_edge or Math.random() < @switch_probability # randomly change direction of wall movement    
    @clip.attr 'y', -@r.y - @padding * 0.5
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