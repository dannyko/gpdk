class @Game
  constructor: (@config = {}) ->
    @element = [] # initialize
    @svg     = d3.select("#game_svg")
    @g       = d3.select("#game_g")
    @width   = @svg.attr("width")
    @height  = @svg.attr("height")
    @scale   = 1 # initialize zoom level (implementation still pending)

  default_collision: -> Collision.list = @element # default collision setup: update the list of elements to use for collision detection

  start: -> Integration.start() # start all elements
    
  stop: -> Integration.stop() # stop all elements