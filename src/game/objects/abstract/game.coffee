class @Game
  constructor: (@config = {}) ->
    @element = [] # initialize
    @svg     = d3.select("#game_svg")
    @g       = d3.select("#game_g")
    @width   = @svg.attr("width")
    @height  = @svg.attr("height")
    @scale   = 1 # initialize zoom level

  default_collision: -> # default collision setup 
    Collision.list = @element # update the list of elements to use for collision detection
    Collision.update_quadtree()  

  start: -> # start new game
    element.start() for element in @element # start element timers
    
  stop: ->
    element.deactivate() for element in @element # stop all element timers