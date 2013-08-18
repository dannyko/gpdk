class @Paddle extends Polygon
  @image_url = GameAssetsUrl + "paddle.png"

  constructor: (@config = {}) ->
    @config.size ||= 90
    h = 14
    @config.path ||= [     # Use default paddle if none defined
             {pathSegTypeAsLetter: 'M', x: -@config.size,  y: -h, react: true},
             {pathSegTypeAsLetter: 'L', x: -@config.size,  y:  h, react: true},
             {pathSegTypeAsLetter: 'L', x:  @config.size,  y:  h, react: true},
             {pathSegTypeAsLetter: 'L', x:  @config.size,  y: -h, react: true},
             {pathSegTypeAsLetter: 'Z'}
             ]    
    @config.fill  = 'red'
    @config.stroke = 'none'
    super(@config)
    @is_root   = true # Make this the player controlled element
    @fixed     = true    
    @r.x       = Game.width / 2
    @r.y       = Game.height - h
    @max_bounce_angle = @config.max_bounce_angle || (9 * Math.PI/20)
    @min_y_speed = @config.min_y_speed || 5
    @image.remove()
    @g.attr("class", "paddle")
    @image = @g.append("image")
      .attr("xlink:href", Paddle.image_url)
      .attr("x", -@size).attr("y", -h)
      .attr("width", @size * 2)
      .attr("height", h * 2)

  redraw: (xy = d3.event) =>
    return unless @collision # don't draw if not active
    @r.x += xy.webkitMovementX
    @r.x = @config.size + 1 if @r.x < @config.size
    @r.x = Game.width - @config.size - 1 if @r.x > Game.width - @config.size
    @draw()

  start: ->
    super
    d3.select(window.top.document.body).on("mousemove", @redraw) # default mouse behavior is to control the root element position
    
  stop: ->
    super
    d3.select(window.top.document.body).on("mousemove", null) # default mouse behavior is to control the root element position

  destroy_check: (n) -> # what happens when root gets hit by a ball
    # n.v.y = -n.v.y
    relative_intersect_x = (@r.x + (@bb_width * 0.5)) - n.r.x
    normalized_relative_intersection_x = relative_intersect_x / (@bb_width * 0.5)
    bounce_angle = normalized_relative_intersection_x * @max_bounce_angle
    n.v.x = Math.cos(bounce_angle) * n.speed
    n.v.y = -1 * Math.sin(bounce_angle) * n.speed    
    if Math.abs(n.v.y) < @min_y_speed
      n.v.y = -@min_y_speed
      n.v.x = Math.sqrt(n.speed * n.speed - @min_y_speed * @min_y_speed)
    # console.log('paddle destroy check', bounce_angle, n.v)
    Collision.resolve(@, n)
    @reaction(n)  

  destroy: ->
    N    = 240 # random color parameter
    fill = '#ff0' 
    dur  = 120 # color effect transition duration parameter
    @image # default reaction
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("fill", @fill())
  
  reaction: (n) -> 
    n.reaction()
    N    = 240 # random color parameter
    fill = '#ff0' 
    dur  = 120 # color effect transition duration parameter
    @image # default reaction
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .transition()
      .duration(dur)
      .ease('linear')
      .attr("fill", @fill())