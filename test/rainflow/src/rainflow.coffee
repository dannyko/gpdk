class @Rainflow extends Game
  constructor: (@config = {}) ->
    super
    @map_width = 360
    @map_height = 180 
    @g.append('image').attr('xlink:href', 'earth_elevation6.png').attr('height', @map_height).attr('width', @map_width)
    @root = new Root()
    @numel    = @config.numel || 5
    @elevation = [] # initialize
    @sleep = 250
    @lastdrop = Utils.timestamp()

    drops = (text) => # callback to execute after text file loads
      row = text.split('\n') 
      @elevation = row.map( (d) -> return d.split(',').map( (d) -> return Number(d) ) ) # matrix rows (m = 180) of elevations indexed by matrix column (n = 360)
      @gravity_param =
        tol: 1 # for computing numerical gradient using a centered finite difference approximation
        energy: V
        type: 'gradient'
      @friction_param =
        alpha: .2
        type: 'friction'
      @svg.on("mousedown", @drop) # default mouse button listener
      d3.select(window).on("keydown", @keydown) # default keyboard listener
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
    dur = 1000
    prompt.transition().duration(dur).attr('opacity', 1).transition().duration(dur).delay(5000).attr('opacity', 0).remove()

    inst = @g.append("text")
      .text("")
      .attr("stroke", "none")
      .attr("fill", "white")
      .attr("font-size", 10)
      .attr("x", @map_width / 2 - 170 )
      .attr("y", @map_height / 4 + 40)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .attr('opacity', 0)
    inst.text("mouse over the map and click a button or press any key to release drops")
    dur = 1000
    inst.transition().delay(dur).duration(dur).attr('opacity', 1).transition().duration(dur).delay(5000).attr('opacity', 0).remove()
      .each('end', -> d3.text('topo_flip.csv', drops) ) # load text data and execute callback)
    
    V = (r) => # energy evaluation function
      # bilinearly interpolated energy, see http://en.wikipedia.org/wiki/Bilinear_interpolation#Algorithm
      # first wrap the input coordinates to an interior point, enforcing periodic boundary conditions
      x   = r.x
      y   = r.y
      x   = @elevation[0].length - 1 + x % (@elevation[0].length - 1) if x < 0 
      x   = x % (@elevation[0].length - 1) if x > @elevation[0].length - 1
      y   = @elevation.length - 1 + y % (@elevation.length - 1) if y < 0
      y   = y % (@elevation.length - 1) if y > @elevation.length - 1
      scale = 1e-4 # units
      energy = scale * Utils.bilinear_interp @elevation, x, y

    updateWindow = () =>
      width  = window.innerWidth || document.documentElement.clientWidth || document.getElementsByTagName('body')[0].clientWidth
      height = window.innerHeight|| document.documentElement.clientHeight|| document.getElementsByTagName('body')[0].clientHeight
     # @svg.attr("width", @width).attr("height", @height)
      # @map.attr("width", @width).attr("height", @height)
      scale = 0.75 * if width > height then height / @map_height else width / @map_width
      scale = Math.floor(scale * 2) * 0.5
      @svg.attr('width', width).attr('height', height)
      @g.attr('transform', 'translate(' + @map_width * 0.5 + ', ' + @map_height * 0.5 + ') scale(' + scale + ')')
      Utils.scale = scale # for access outside of the Game object
      return
    updateWindow()
    window.onresize = updateWindow
    # console.log(d3.selectAll('g'), @element.map (d) -> [d.height, d.width])
    # @root = new Root() # default root element i.e. under user control

  drop: (r = @root.r) =>
    stamp = Utils.timestamp()
    return unless stamp - @lastdrop > @sleep 
    @lastdrop = stamp
    config = []
    for i in [0..@numel - 1]
      dr = new Vec({x: 2 * @root.size * (Math.random() - 0.5), y: 2 * @root.size * (Math.random() - 0.5)})
      config.push
        r: new Vec(r).add(dr)
        force_param: [new ForceParam(@gravity_param), new ForceParam(@friction_param)]
        width: @map_width
        height: @map_height
    return unless config.length > 0
    dur = 100
    new_drop = -> new Drop(config.pop())
    int = setInterval(new_drop, dur)
    clear = -> clearInterval(int)
    setTimeout(clear, dur * (config.length + 1))

  keydown: () =>
    @drop() # any key releases a drop
    return    