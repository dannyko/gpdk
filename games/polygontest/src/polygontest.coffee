class @Polygontest extends Game
  constructor: (@config = {}) ->
    super
    @numel    = @config.numel || 64
    @size     = 15 # polygon size
    for i in [0..@numel - 1] # create element list
      newPolygon = new TestPolygon({size: @size})
      @element.push(newPolygon) # extend the array of all elements in this game
    for k in [0..Math.ceil(Math.sqrt(@element.length))] # place elements on grid
      for j in [0..Math.ceil(Math.sqrt(@element.length))]
        i = k * Math.floor(Math.sqrt(@element.length)) + j
        break if i > @element.length - 1
        @element[i].r.x = @width  * 0.5 +  k  * (@element[i].pathwidth + 2 * @element[i].tol) - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
        @element[i].r.y = @height * 0.25 + j  * (@element[i].pathheight + 1 * @element[i].tol)
        @element[i].draw()
    @root = new Root() # default root element i.e. under user control
    @element.push(@root)
    @init()

  start: () ->
    element.start() for element in @element # start element timers
    @svg.style("cursor", "none")
    # @zoom() # set initial zoom level for the elements to fill the available space
    # d3.timer((d) => @zoom(d)) # start the zoom timer after the element timers 