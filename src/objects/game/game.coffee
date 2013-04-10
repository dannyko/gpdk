class @Game
  constructor: (@config = {}) ->
    @initialN = @config.initialN || 5
    @N        = @initialN
    @element  = [] # initialize
    @svg      = d3.select("#game_svg")
    @g        = d3.select("#game_g")
    @width    = @svg.attr("width")
    @height   = @svg.attr("height")
    @zoomTick = 0 # 5000 # ms spacing between zoom draws    
    @tzoom    = 0 # integer counter for tracking zoom timer
    @scale    = 1 # initialize zoom level
    @root     = new Root() # default root element i.e. under user control
    @scoretxt = @g.append("text").text("").attr("stroke", "none").attr("fill", "white").attr("font-size", "18").attr("x", "20").attr("y", "40").attr('font-family', 'arial black')
    @lives    = @g.append("text").text("").attr("stroke", "none").attr("fill", "white").attr("font-size", "18").attr("x", "20").attr("y", "20").attr('font-family', 'arial black')
    @leveltxt = @g.append("text").text("").attr("stroke", "none").attr("fill", "white").attr("font-size", "18").attr("x", "20").attr("y", "60").attr('font-family', 'arial black')
    d3.select(window).on("keydown", @keydown) # default keyboard listener
    @score    = @config.score || 0

  start: -> # start new game
    @root.draw()
    @root.go = true # start bullet firing without allowing root movement
    
  stop: ->
    element.deactivate() for element in @element # stop all element timers
    @root.deactivate()
    # if @root.lives < 0
      # @reset()
    # @zoom() # set initial zoom level for the elements to fill the available space
    # d3.timer((d) => @zoom(d)) # start the zoom timer after the element timers 

  reset: =>
    @g.selectAll("g").remove()
    @lives.text("")
    @scoretxt.text("")
    @leveltxt.text("")
    @svg.style("cursor", "auto")
    @N = @initialN
    @score = 0
    @root = new Root()
    Gamescore.lives = Gamescore.initialLives
    @start()