class @Drone extends Circle
  @url = GameAssetsUrl + "drone_1.png"

  constructor: (@config = {}) ->
    @config.size = 20
    super(@config)
    @stop()
    @max_speed = 15 
    @image.remove()
    @g.attr("class", "drone")
    @image = @g.append("image")
      .attr("xlink:href", Drone.url)
      .attr("x", -@size).attr("y", -@size)
      .attr("width", @size * 2)
      .attr("height", @size * 2)
        
  destroy: (remove = false) ->
    super(remove)
    dur = 100
    N = 320
    fill = "hsl(" + Math.random() * N + ", 50%, 70%)"
    @g.append("circle")
      .attr("r", @size)
      .attr("x", 0)
      .attr("y", 0)
      .transition()
      .duration(dur)
      .ease('sqrt')
      .attr("fill", fill)
      .remove()
    @g.attr("class", "")
      .transition()
      .delay(dur)
      .duration(dur * 2)
      .ease('sqrt')
      .style("opacity", "0")
      .remove() 
    
  draw: ->
    @angle = -Math.atan2(@f.x, @f.y) # spin the image so that it faces the root element at all times
    @v.normalize(@max_speed) if @v.length() > @max_speed
    super