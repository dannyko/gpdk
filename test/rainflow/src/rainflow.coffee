class @Rainflow extends Game
  constructor: (@config = {}) ->
    super
    @map_width = 360
    @map_height = 180 
    @g.append('image').attr('xlink:href', 'earth_elevation4.png').attr('height', @map_height).attr('width', @map_width)
    @svg.on("mousedown", @drop) # default mouse button listener
    d3.select(window).on("keydown", @keydown) # default keyboard listener
    # @svg.on("mousewheel", @spin) # default scroll wheel listener
    # @numel    = @config.numel || 100
    # for i in [0..@numel - 1] # create element list
    #   newCircle = new TestCircle()
    #   @element.push(newCircle) # extend the array of all elements in this game
    #   @element[i].r.x = @map_width * Math.random()
    #   @element[i].r.y = @map_height * Math.random()
    #   @element[i].draw()
    @elevation = []
    
    V = (r) => # energy evaluation function
      # bilinearly interpolated energy, see http://en.wikipedia.org/wiki/Bilinear_interpolation#Algorithm
      # first wrap the input coordinates to an interior point, enforcing periodic boundary conditions
      x   = r.x
      y   = r.y
      x   = @elevation[0].length - 1 + x % (@elevation[0].length - 1) if x < 0 
      x   = x % (@elevation[0].length - 1) if x > @elevation[0].length - 1
      y   = @elevation.length - 1 + y % (@elevation.length - 1) if y < 0
      y   = y % (@elevation.length - 1) if y > @elevation.length - 1
      tol = 1e-12 # small number for offset in case x = Math.floor(x)
      xf  = Math.floor(x)
      xc  = Math.ceil(x + tol)
      yf  = Math.floor(y)
      yc  = Math.ceil(y + tol)
      dxf = x - xf
      dxc = xc - x
      dyf = y - yf
      dyc = yc - y
      v_r = @elevation[yf][xf] * dxc * dyc + @elevation[yf][xc] * dxf * dyc + @elevation[yc][xf] * dxc * dyf + @elevation[yc][xc] * dxf * dyf
      v_r *= 1 / ((xc - xf) * (yc - yf)) # bilinear approximation of scalar energy value from discrete data array

    drops = (text) => # callback to execute after text file loads
      row = text.split('\n') 
      @elevation = row.map( (d) -> return d.split(',').map( (d) -> return Number(d) ) ) # matrix rows (m = 180) of elevations indexed by matrix column (n = 360)
      @gravity_param =
        tol: 0.01 # for computing numerical gradient using a centered finite difference approximation
        energy: V
        type: 'gradient'
      @friction_param =
        alpha: 10
        type: 'friction'
      @root = new Root()
      @start()

    d3.text('topo_flip.csv', drops) # load text data and execute callback

    updateWindow = () =>
      width  = window.innerWidth || document.documentElement.clientWidth || document.getElementsByTagName('body')[0].clientWidth
      height = window.innerHeight|| document.documentElement.clientHeight|| document.getElementsByTagName('body')[0].clientHeight
     # @svg.attr("width", @width).attr("height", @height)
      # @map.attr("width", @width).attr("height", @height)
      scale = 0.75 * if width > height then height / @map_height else width / @map_width
      @svg.attr('width', width).attr('height', height)
      @g.attr('transform', 'translate(' + (width - scale * @map_width) * 0.5 + ', ' + (height - scale * @map_height) * 0.5 + ') scale(' + scale + ')')
      Utils.scale = scale # for access outside of the Game object
      return
    updateWindow()
    window.onresize = updateWindow
    # console.log(d3.selectAll('g'), @element.map (d) -> [d.height, d.width])
    # @root = new Root() # default root element i.e. under user control

  drop: () =>
    config = 
      r: new Vec(x: @root.r.x, y: @root.r.y)
      force: [new Force(@gravity_param), new Force(@friction_param)]
      width: @map_width
      height: @map_height
    new Drop(config)

  keydown: () =>
    @drop() # any key releases a drop
    return    