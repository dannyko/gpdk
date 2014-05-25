class $z.Drone extends $z.Circle
  @url = GameAssetsUrl + "drone.svg"
  @max_speed = 3

  constructor: (@config = {}) ->
    @config.size = 30
    super(@config)
    @root   = @config.root
    @param  = {type: 'charge', cx: null, cy: null, q: null}
    @set_param()
    @max_speed = $z.Drone.max_speed
    @invincible = false 
    @energy = @config.energy || 10
    @image.remove()
    @g.attr("class", "drone")
    @image = @g.insert("image", ":first-child")
      .attr("xlink:href", $z.Drone.url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
    @overlay.attr("r", @size * .85)
        .attr("x", 0)
        .attr("y", 0)
        .style('fill', '#FF0')
        .style('opacity', 0)

  set_param: ->
    @param.cx       = @root.r.x
    @param.cy       = @root.r.y
    @param.q        = if @collision then @root.charge * (1 + $z.Gamescore.value / 1000) else 1e-6 # charge, avoid hard zero to preserver angle / rotation of drone (no NaN)
    @force_param[0] = @param

  draw: ->
    @angle = -Math.atan2(@f.x, @f.y) # spin the image so that it faces the root element at all times
    # console.log(@v.x, @v.y)
    @v.normalize(@max_speed) if @v.length() > @max_speed
    @set_param()
    super
    
  start: ->
    v0           = 1 + $z.Gamescore.value * 0.0001 * $z.Drone.max_speed 
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
      d.max_speed = $z.Drone.max_speed
      d.invincible = false
    )

  flash: () ->
    return if @is_flashing # wait until previous flash finishes
    @is_flashing = true
    dur = 100
    flashColor = '#FFF'
    depletion = 1 - @energy / @config.energy # a number between 0 and 1 signifying the degree of depletion
    @overlay.style('fill', d3.interpolateRgb('#600', '#FF0')(depletion)) # update fill color
    @g.append("circle")
      .attr("r", @size * .85)
      .attr("x", 0)
      .attr("y", 0)
      .style('fill', flashColor)
      .style('opacity', .4)
      .transition()
      .delay(dur)
      .duration(dur)
      .style('opacity', 0)
      .ease('linear')
      .remove()
      .each('end', (d) ->
        d.overlay.style('opacity', depletion * 0.5)
        d.is_flashing = false
      )

  deplete: (power = 1) ->
    return if @invincible
    @energy = @energy - power
    @flash()
    $z.Game.sound?.play('shot') if $z.Game.audioSwitch
    return

  depleted: ->
    if @energy <= 0 then true else false

  remove: ->
    return if @is_removed or not @collision
    dur = 800
    if $z.Gamescore.lives >= 0
      @collision = false # prevent additional reactions from occuring while transition lasts
      $z.Game.sound.play('boom') if $z.Game.audioSwitch
      @overlay.style('opacity', 0.6)
      @g.append('circle') # overlay #2
        .attr("x", 0)
        .attr("y", 0)
        .attr("r", @size * 0.85)
        .style('fill', '#FF0')
        .style('opacity', 0.8)
        .transition()
        .duration(dur)
        .ease('linear')
        .style('opacity', 0)
        .remove()
      @g.append('circle') # expanding red overlay
        .attr("x", 0)
        .attr("y", 0)
        .attr("r", @size)
        .style('fill', '#600')
        .style('opacity', 0.8)
        .attr('transform', 'scale(1)') 
        .transition()
        .duration(dur)
        .ease('linear')
        .attr('transform', 'scale(5.5)')
        .remove()
      @g.transition()
       .duration(dur)
       .ease('poly(0.5)')
       .style("opacity", "0")
       .each('end', (d) -> 
         d.is_removed = true
         d.overlay.style('opacity', 0)
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
      super(dur)
    $z.Game.instance.level() if $z.Game.instance.element.every (d) -> not d.collision
    return
    
  offscreen: -> 
    return if $z.Gamescore.lives < 0
    dx  = $z.Game.width * 0.5 - @r.x 
    dy  = $z.Game.height * 0.5 - @r.y
    d   = Math.sqrt(dx * dx + dy * dy) 
    scale = 0.01 * @max_speed / d
    if Math.abs(dx) > $z.Game.width * 0.5 - @size
      @v.x += scale * dx
    if Math.abs(dy) > $z.Game.height * 0.5 - @size
      @v.y += scale * dy
    if super()
      @r.x = Math.min(Math.max(0, @r.x), $z.Game.width)
      @r.y = Math.min(Math.max(0, @r.y), $z.Game.height)
    return false