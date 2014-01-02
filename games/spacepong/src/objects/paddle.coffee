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
    @padding   = 50
    @r.x       = Game.width / 2
    @r.y       = Game.height - @height - @padding
    @min_y_speed = @config.min_y_speed || 8
    @max_x     = Game.width - @config.size - @tol - @padding
    @min_x     = @config.size + @tol + @padding
    @overshoot = @padding
    @image.remove()
    @g.attr("class", "paddle")
    @image = @g.append("image")
     .attr("xlink:href", Paddle.image_url)
     .attr("x", -@size - @overshoot).attr("y", -@height)
     .attr("width", @size * 2 + @overshoot * 2)
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

  redraw: (e = d3.event) =>
    return unless @collision # don't draw if not active
    @r.x += (e.dx || e.movementX || e.mozMovementX || e.webkitMovementX || 0) / Game.scale
    @r.x = @min_x if @r.x < @min_x
    @r.x = @max_x if @r.x > @max_x
    return

  start: ->
    super
    d3.select(window.top).on("mousemove", @redraw) # default mouse behavior is to control the root element position
    d3.select(window).on("mousemove", @redraw) if window isnt window.top # default mouse behavior is to control the root element position
    @svg.call(d3.behavior.drag().origin(Object).on("drag", @redraw))
    
  stop: ->
    super
    d3.select(window.top).on("mousemove", null) # default mouse behavior is to control the root element position
    d3.select(window).on("mousemove", null) if window isnt window.top # default mouse behavior is to control the root element position if game is in iframe
    @svg.call(d3.behavior.drag().origin(Object).on("drag", null))

  destroy_check: (n) -> # what happens when paddle gets hit by a ball
    if n.type is 'Circle' # hit a ball
      intersect_x        = n.r.x - @r.x
      relative_intersect = intersect_x / @size
      L = 0.8
      relative_intersect *= L
      relative_intersect = -L if relative_intersect < -L
      relative_intersect =  L if relative_intersect >  L
      relative_intersect = .1 if relative_intersect == 0
      n.v.x = relative_intersect * n.speed
      n.v.y = -Math.sqrt(n.speed * n.speed - n.v.x * n.v.x) # value of v.y determined from v.x by the Pythagorean theorem since speed is constant
      @reaction(n)  
    else # hit a ship
      n.destroy()
  
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