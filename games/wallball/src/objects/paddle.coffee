class @Paddle extends Polygon
  @image_url = GameAssetsUrl + "paddle.png"

  constructor: (@config = {}) ->
    @config.size ||= 90
    @height = 14
    @config.path ||= [     # Use default paddle if none defined
             {pathSegTypeAsLetter: 'M', x: -@config.size,  y: -@height, react: true},
             {pathSegTypeAsLetter: 'L', x: -@config.size,  y:  @height, react: true},
             {pathSegTypeAsLetter: 'L', x:  @config.size,  y:  @height, react: true},
             {pathSegTypeAsLetter: 'L', x:  @config.size,  y: -@height, react: true},
             {pathSegTypeAsLetter: 'Z'}
             ]    
    @config.fill  = 'red'
    @config.stroke = 'none'
    super(@config)
    @is_root   = true # Make this the player controlled element
    @fixed     = true    
    @r.x       = Game.width / 2
    @r.y       = Game.height - @height
    @min_y_speed = @config.min_y_speed || 8
    @max_x     = Game.width - @config.size - @tol
    @min_x     = @config.size + @tol
    @image.remove()
    @g.attr("class", "paddle")
    @image = @g.append("image")
     .attr("xlink:href", Paddle.image_url)
     .attr("x", -@size).attr("y", -@height)
     .attr("width", @size * 2)
     .attr("height", @height * 2)

  nudge: (sign) ->
    dist = 2 * @size
    dx   = 20 * sign
    x1   = @r.x + dist * sign
    x1   = @max_x if x1 > @max_x
    x1   = @min_x if x1 < @min_x
    func = =>
      done = false
      done = true if (@r.x >= x1 and dx > 0) or (@r.x <= x1 and dx < 0)
      @r.x += dx unless done
      @r.x = @max_x if @r.x > @max_x
      @r.x = @min_x if @r.x < @min_x
      done
    d3.timer(func)

  redraw: (xy = d3.event) =>
    return unless @collision # don't draw if not active
    @r.x += xy.webkitMovementX
    @r.x = @min_x if @r.x < @min_x
    @r.x = @max_x if @r.x > @max_x
    @draw()

  start: ->
    super
    d3.select(window.top).on("mousemove", @redraw) # default mouse behavior is to control the root element position
    
  stop: ->
    super
    d3.select(window.top).on("mousemove", null) # default mouse behavior is to control the root element position

  destroy_check: (n) -> # what happens when root gets hit by a ball
    console.log(n) if n.type isnt 'Circle'
    intersect_x        = n.r.x - @r.x
    relative_intersect = intersect_x / @size
    relative_intersect = -1 if relative_intersect < -1
    relative_intersect =  1 if relative_intersect > 1
    relative_intersect = 0.01 if relative_intersect == 0
    n.v.x = relative_intersect * n.speed
    n.v.y = -Math.sqrt(n.speed * n.speed - n.v.x * n.v.x)
    if Math.abs(n.v.y) < @min_y_speed
      n.v.y = -@min_y_speed
      x_spd = Math.sqrt(n.speed * n.speed - @min_y_speed * @min_y_speed)
      n.v.x =  x_spd if relative_intersect > 0
      n.v.x = -x_spd if relative_intersect < 0
    # n.r.y = Game.height - 2 * @height - n.size - n.tol
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