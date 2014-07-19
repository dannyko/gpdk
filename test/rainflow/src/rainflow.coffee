class $z.Rainflow extends $z.Game
  constructor: (@config = {}) ->
    $z.Game.height = 180
    $z.Game.width  = 360
    super
    @map_width     = 360
    @map_height    = 180 
    @image         = @g.append('image')
      .attr('xlink:href', 'earth_elevation6.png')
      .attr('height', @map_height)
      .attr('width', @map_width)
    @root      = $z.Factory.spawn($z.Root)
    @numel     = @config.numel || 20
    @elevation = [] # initialize
    @lastdrop  = $z.Utils.timestamp()
    @raining   = false
    
    drops = (text) => # callback to execute after text file loads
      row            = text.split('\n') 
      @elevation     = row.map( (d) -> return d.split(',').map( (d) -> return Number(d) ) ) # matrix rows (m = 180) of elevations indexed by matrix column (n = 360)
      @gravity_param =
        tol: 1 # for computing numerical gradient using a centered finite difference approximation
        energy: V
        type: 'gradient'
      @friction_param =
        alpha: .2
        type: 'friction'
      @svg.on("click", @drop) # default mouse button listener
      # d3.select(window).on("keydown", @keydown) # default keyboard listener
      @start()

    prompt = @g.append("text")
      .text("")
      .attr("stroke", "black")
      .attr("fill", "deepskyblue")
      .attr("font-size", "36")
      .attr("x", @map_width / 2 - 100 )
      .attr("y", @map_height / 4)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .attr('opacity', 0)
    prompt.text("RAINFLOW")
    dur = 1500
    prompt.transition()
      .duration(dur)
      .attr('opacity', 1)
      .transition()
      .duration(dur)
      .delay(dur)
      .attr('opacity', 0)
      .remove()

    inst = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", 10)
      .attr("x", @map_width / 2 - 100 )
      .attr("y", @map_height / 4 + 40)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .attr('opacity', 0)

    inst.text("click to make it rain")
    inst.transition()
      .duration(dur)
      .attr('opacity', 1)
      .transition()
      .duration(dur)
      .attr('opacity', 0)
      .remove()
      .each('end', -> d3.text('topo_flip.csv', drops) ) # load text data and execute callback)
    
    V = (r) => # energy evaluation function
      # bilinearly interpolated energy, see http://en.wikipedia.org/wiki/Bilinear_interpolation#Algorithm
      # first wrap the input coordinates to an interior point, enforcing periodic boundary conditions
      x      = r.x
      y      = r.y
      x      = @elevation[0].length - 1 + x % (@elevation[0].length - 1) if x < 0 
      x      = x % (@elevation[0].length - 1) if x > @elevation[0].length - 1
      y      = @elevation.length - 1 + y % (@elevation.length - 1) if y < 0
      y      = y % (@elevation.length - 1) if y > @elevation.length - 1
      scale  = 1e-4 # units
      energy = scale * $z.Utils.bilinear_interp @elevation, x, y

  drop: (r = @root.r) =>
    stamp = $z.Utils.timestamp()
    return if @raining
    @raining = true
    @lastdrop = stamp
    config = []
    for i in [0..@numel - 1]
      dr = $z.Factory.spawn($z.Vec, {x: 2 * @root.size * (Math.random() - 0.5), y: 2 * @root.size * (Math.random() - 0.5)})
      config.push
        r: $z.Factory.spawn($z.Vec, r).add(dr)
        force_param: [$z.Factory.spawn($z.ForceParam, @gravity_param), $z.Factory.spawn($z.ForceParam, @friction_param)]
        width: @map_width
        height: @map_height
    return unless config.length > 0
    dur      = 10
    new_drop = -> 
      $z.Factory.spawn($z.Drop, config.pop()).start()
      if config.length is 0
        console.log('clearing')
        clear()
        $z.Game.instance.raining = false
    int      = setInterval(new_drop, dur)
    clear    = -> clearInterval(int)
    
$(document).ready( -> 
  new $z.Rainflow() # create the game instance
)