class @Drone extends Circle
  @url = GameAssetsUrl + "drone_1.png"
  @max_speed = 4

  constructor: (@config = {}) ->
    @config.size = 25
    super(@config)
    @root   = @config.root
    @param  = {type: 'charge', cx: null, cy: null, q: null}
    @set_param()
    @max_speed = Drone.max_speed
    @invincible = false 
    @energy = @config.energy || 10
    @image.remove()
    @g.attr("class", "drone")
    @image = @g.append("image")
      .attr("xlink:href", Drone.url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
    @overlay = @g.append('circle')

  set_param: ->
    @param.cx       = @root.r.x
    @param.cy       = @root.r.y
    @param.q        = @root.charge * (1 + Gamescore.value / 1000) # charge 
    @force_param[0] = @param

  draw: ->
    @angle = -Math.atan2(@f.x, @f.y) # spin the image so that it faces the root element at all times
    @v.normalize(@max_speed) if @v.length() > @max_speed
    @set_param()
    super
    
  start: ->
    v0           = 1 + Gamescore.value * 0.0001 * Drone.max_speed 
    @max_speed   = 0
    dur          = 1000
    @invincible  = true
    super(dur, (d) -> 
      dx         = d.root.r.x - d.r.x
      dy         = d.root.r.y - d.r.y
      d1         = Math.sqrt(dx * dx + dy * dy)
      dx        /= d1
      dy        /= d1
      d.v.x = v0 * dx
      d.v.y = v0 * dy
      d.max_speed = Drone.max_speed
      d.invincible = false
    )

  deplete: (power = 1) ->
    return if @invincible
    @energy = @energy - power
    dur = 50
    fill0 = '#300'
    fill = "#FF0"
    @g.select("circle")
      .attr("r", @size * .9)
      .attr("x", 0)
      .attr("y", 0)
      .style('fill', fill)
      .style('opacity', (1 - @energy / @config.energy) * .4)
    Game.sound?.play('shot') if Game.audioSwitch
    return

  depleted: ->
    if @energy <= 0 then true else false

  remove: (effects = Gamescore.lives >= 0) ->
    @is_removed = true
    Game.sound.play('boom') if Game.audioSwitch and effects
    dur = 800
    if effects
      @overlay
        .attr("r", @size * .9)
        .attr("x", 0)
        .attr("y", 0)
        .style('fill', '#800')
        .style('opacity', .7)
        .transition()
        .duration(dur)
        .attr('transform', 'scale(5)')
        .ease('linear')
        .each('end', => @overlay.attr('transform', 'scale(1)'))
      @g.transition()
       .duration(dur)
       .ease('linear')
       .style("opacity", "0")
       .each('end', =>
          super()
        )
      scaleSwitch = false
      if scaleSwitch
        @image
         .attr('transform', 'scale(1)')
         .transition()
         .duration(dur)
         .ease('linear')
         .attr('transform', 'scale(5)')
    else
      @fadeOut(dur)
      super
    Game.instance.level() if Game.instance.element.every (d) -> d.is_removed
    return
    
  init: ->
     super
     @image.attr('transform', 'scale(1)')
     @overlay.style('opacity', 0)

  offscreen: -> 
    dx  = @r.x - Game.width * 0.5
    dy  = @r.y - Game.height * 0.5 
    dr2 = dx * dx + dy * dy 
    scale = Game.width / Game.height
    if dr2 > Game.height * Game.height * 0.25 * scale * scale
      scale = .01
      Force.eval(@, @force_param[0], @f)
      @v.add(@f.normalize(@max_speed * scale))
    return false