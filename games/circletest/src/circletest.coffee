class @Circletest 
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
    for i in [0..@numel - 1] # create element list
      newCircle = new TestCircle()
      @element.push(newCircle) # extend the array of all elements in this game
    for k in [0..Math.ceil(Math.sqrt(@element.length))] # place elements on grid
      for j in [0..Math.ceil(Math.sqrt(@element.length))]
        i = k * Math.floor(Math.sqrt(@element.length)) + j
        break if i > @element.length - 1
        @element[i].r.x = @width  * 0.5 + k   * @element[i].size * 2 + @element[i].tol - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
        @element[i].r.y = @height * 0.25 + j  * @element[i].size  * 2  + @element[i].tol
        @element[i].draw()
    @root = new Root() # default root element i.e. under user control
    # @element.push(@root) # add the newly created root element to the array of all elements
    Collision.list = @element # update the list of elements to use for collision detection
    Collision.update_quadtree()

  start: () ->
    element.start() for element in @element # start element timers
    @svg.style("cursor", "none")
    # @zoom() # set initial zoom level for the elements to fill the available space
    # d3.timer((d) => @zoom(d)) # start the zoom timer after the element timers 