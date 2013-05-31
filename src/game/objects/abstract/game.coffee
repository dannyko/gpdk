class @Game
  constructor: (@config = {}) ->
    @element = [] # initialize game element list
    @width   = 800 # default width
    @height  = 600 # default height
    @svg     = d3.select("#game_svg")
    @svg     = d3.select('body').append('svg')
      .attr('width', @width + 'px')
      .attr('height', @height + 'px')
      .attr('id', 'game_svg') if @svg.empty()
    @canvas  = d3.select('#game_canvas')
    @canvas  = d3.select('body')
      .append('canvas')
      .attr('width', @width + 'px')
      .attr('height', @height + 'px') if @canvas.empty()
    @canvas  = @canvas.node().getContext('2d')
    @g       = d3.select("#game_g")
    @g       = @svg.append('g') if @g.empty()
    @g.attr('id', 'game_g')
	    .attr('width', @svg.attr('width'))
	    .attr('height', @svg.attr('height'))
	    .style('width', '')
	    .style('height', '')
    @scale   = 1 # initialize zoom level (implementation still pending)

  start: -> Integration.start() # start all elements
    
  stop: -> Integration.stop() # stop all elements