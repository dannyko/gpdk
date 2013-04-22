class @Game
  constructor: (@config = {}) ->
    @element = [] # initialize
    @svg     = d3.select("#game_svg")
    @g       = d3.select("#game_g")
    @width   = @svg.attr("width")
    @height  = @svg.attr("height")
    @scale   = 1 # initialize zoom level

  start: -> # start new game
    
  stop: ->
    element.deactivate() for element in @element # stop all element timers