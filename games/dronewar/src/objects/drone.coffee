class @Drone extends Circle
  @url = GameAssetsUrl + "drone_1.png"

  constructor: (@config = {}) ->
    @config.size = 20
    super(@config)
    @stop()
    @max_speed = 12
    @energy = @config.energy || 1
    @image.remove()
    @g.attr("class", "drone")
    @image = @g.append("image")
      .attr("xlink:href", Drone.url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
        
  deplete: (power = 1) ->
    @energy = @energy - power
    dur = 50
    fill = "#FF0"
    last = @g.select('circle:last-child')
    if last isnt @image then last.remove()
    @g.append("circle")
      .attr("r", @size * .9)
      .attr("x", 0)
      .attr("y", 0)
      .style("fill", fill)
      .style("opacity", 0)
      .transition()
      .duration(dur * 0.5)
      .ease('sqrt')
      .style('opacity', 0.5)
      .transition()
      .duration(dur * 0.5)
      .ease('linear')
      .style('opacity', (1 - @energy / @config.energy) * .6)

  depleted: ->
    if @energy <= 0 then true else false

  destroy: (remove = false) ->
    super(remove)
    dur = 100
    @g.attr("class", "")
      .transition()
      .duration(dur)
      .ease('sqrt')
      .style("opacity", "0")
      .remove() 
    
  draw: ->
    @angle = -Math.atan2(@f.x, @f.y) # spin the image so that it faces the root element at all times
    @v.normalize(@max_speed) if @v.length() > @max_speed
    super

  offscreen: -> 
    dx  = @r.x - Game.width * 0.5
    dy  = @r.y - Game.height * 0.5 
    dr2 = dx * dx + dy * dy 
    scale = .8
    if dr2 > Game.height * Game.height * 0.25 * scale * scale
      scale = .01
      f  =  Force.eval(@, @force_param[0])
      @v.add(f.normalize(@max_speed * scale))
    return false