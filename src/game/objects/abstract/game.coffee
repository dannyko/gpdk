class @Game
  
  ## class variables:
  @width:  null # class variable for easy access from other objects
  @height: null # class variable for easy access from other objects
  @score = 0 # default initial game score
  @score_increment = 100 # default score increment
  @initialLives = 2 # default number of extra lives
  @lives = @initialLives # i.e. 3 lives total by default including the starting element

  ## class methods:
  @increment_score: -> # increase the value by the increment
    @score += @score_increment # update current game score value

  @decrement_score: -> # increase the value by the increment
    @score -= @score_increment # update current game score value

  constructor: (@config = {}) ->
    @element    = [] # initialize
    @svg        = d3.select("#game_svg")
    @svg        = d3.select('body').append('svg').attr('width', '800px').attr('height', '600px').attr('id', 'game_svg') if @svg.empty()
    Game.width  = parseInt(@svg.attr("width"), 10)
    Game.height = parseInt(@svg.attr("height"), 10)
    @scale      = 1 # initialize zoom level (implementation still pending)
    @g          = d3.select("#game_g")
    @g          = @svg.append('g') if @g.empty()
    @g.attr('id', 'game_g')
	    .attr('width', @svg.attr('width'))
	    .attr('height', @svg.attr('height'))
	    .style('width', '')
	    .style('height', '')

  start: -> Physics.start() # start all elements
    
  stop: -> Physics.stop() # stop all elements

  end: (callback = ->) -> # end the game by returning true i.e. stopping any d3 "progress" timer
    if Gameprez?
      Gameprez.end(Game.score, callback)
    else 
      callback()
    return true # game over so return true to stop the d3 timer calling @progress()


  cleanup: -> # remove all elements from Collision list and set to object reference to null
    len = Collision.list.length
    while (len--) # decrementing avoids potential indexing issues after popping last element off
      element = Collision.list.pop()
      element.destroy()
      element = null