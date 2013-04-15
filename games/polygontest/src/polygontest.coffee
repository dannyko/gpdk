class @Polygontest 
  constructor: (@config = {}) ->
    @numel    = @config.numel || 64
    @element  = [] # initialize
    @svg      = d3.select("#game_svg")
    @g        = d3.select("#game_g")
    @width    = @svg.attr("width")
    @height   = @svg.attr("height")
    @zoomTick = 0 # 5000 # ms spacing between zoom draws    
    @tzoom    = 0 # integer counter for tracking zoom timer
    @scale    = 1 # initialize zoom level
    @size     = 10 # polygon size
    for i in [0..@numel - 1] # create element list
      newPolygon = new Polygon({size: @size})
      for j in [0..@element.length - 1] # loop over all elements and add a new Circle to their neighbor lists
        continue if not @element[j]?
        newPolygon.n.push(@element[j]) # add the newly created element to the neighbor list
        @element[j].n.push(newPolygon) # add the newly created element to the neighbor list
      @element.push(newPolygon) # extend the array of all elements in this game
    #@element[0].r.x = @width  * 0.5 + 0   * @element[0].size * 2 + @element[0].tol - Math.ceil(Math.sqrt(@element.length)) * @element[0].size 
    #@element[0].r.y = @height * 0.25 + 0  * @element[0].size  * 2  + @element[0].tol
    #@element[0].draw()
    #@element[1].r.x = @width  * 0.5 + 0   * @element[1].size * 2 + @element[1].tol - Math.ceil(Math.sqrt(@element.length)) * @element[1].size 
    #@element[1].r.y = @height * 0.25 + 1  * @element[1].size  * 2  + @element[1].tol
    #@element[1].draw()
    for k in [0..Math.ceil(Math.sqrt(@element.length))] # place elements on grid
      for j in [0..Math.ceil(Math.sqrt(@element.length))]
        i = k * Math.floor(Math.sqrt(@element.length)) + j
        break if i > @element.length - 1
        @element[i].r.x = @width  * 0.5 + k   * @element[i].size * 2 + @element[i].tol - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
        @element[i].r.y = @height * 0.25 + j  * @element[i].size  * 2  + @element[i].tol
        @element[i].draw()
    @root = new Root() # default root element i.e. under user control
    for element in @element
      @root.n.push(element)
      element.n.push(@root) 
    @element.push(@root) # add the newly created root element to the array of all elements

  start: () ->
    element.start() for element in @element # start element timers
    # @zoom() # set initial zoom level for the elements to fill the available space
    # d3.timer((d) => @zoom(d)) # start the zoom timer after the element timers 