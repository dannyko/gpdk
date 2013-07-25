class @Paddle extends Polygon
  constructor: (@config = {}) ->
    @config.path ||= [     # Use default paddle if none defined
             {pathSegTypeAsLetter: 'M', x: -150,  y: -5, react: true},
             {pathSegTypeAsLetter: 'L', x: -150,  y: 5, react: true},
             {pathSegTypeAsLetter: 'L', x: 150,  y: 5, react: true},
             {pathSegTypeAsLetter: 'L', x: 150,  y: -5, react: true},
             {pathSegTypeAsLetter: 'Z'}
             ]    
    super(@config)
    @is_root   = true # Make this the player controlled element
    @fixed     = true    
    @size      = 90
    @angleStep = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @stroke("#700")
    @fill("red")

    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)
    @r.x       = @width / 2
    @r.y       = @height - @bb_height * 0.5

  redraw: (xy = d3.mouse(@svg.node())) =>
    return unless @collision # don't draw if not active
    @r.x = xy[0]
    @draw()

  start: ->
    super
    @svg.on("mousemove", @redraw) # default mouse behavior is to control the root element position
    
  stop: ->
    super
    @svg.on("mousemove", null) # default mouse behavior is to control the root element position

  death_check: (n) ->
    n.death()
    @death()
    Gamescore.lives -= 1 # decrement lives for this game
  
  death: ->
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
  
  reaction: (n) -> # what happens when root gets hit by a ball
    n.v.y = -n.v.y
    n.r.y -= @r.y - n.r.y + @tol
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