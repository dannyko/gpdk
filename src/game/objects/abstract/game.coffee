class @Game
  constructor: (@config = {}) ->
    @element = [] # initialize
    @svg     = d3.select("#game_svg")
    @svg     = d3.select('body').append('svg').attr('width', '800px').attr('height', '600px').attr('id', 'game_svg') if @svg.empty()
    @width   = parseInt(@svg.attr("width"), 10)
    @height  = parseInt(@svg.attr("height"), 10)
    @scale   = 1 # initialize zoom level (implementation still pending)
    @g       = d3.select("#game_g")
    @g       = @svg.append('g') if @g.empty()
    @g.attr('id', 'game_g')
	    .attr('width', @svg.attr('width'))
	    .attr('height', @svg.attr('height'))
	    .style('width', '')
	    .style('height', '')

  start: -> Integration.start() # start all elements
    
  stop: -> Integration.stop() # stop all elements