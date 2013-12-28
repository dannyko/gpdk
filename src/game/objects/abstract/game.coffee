class @Game
  
  @width:  null # class variable for easy access from other objects
  @height: null # class variable for easy access from other objects
  @scale:  1 # class variable for global scaling transformations

  get_scale = (padding = 4) -> # minimal padding to prevent browser scrollbar issues 
    element        = window.top.document.body # .getElementsByTagName('iframe')[0]
    x              = $(element).width()
    y              = $(element).height()
    x              = Math.min(x, $(window).width())
    y              = Math.min(y, $(window).height())
    x              = Math.min(x, $(window.top).width())
    y              = Math.min(y, $(window.top).height())
    x              = (x - padding) if x > padding and padding > 0
    y              = (y - padding) if y > padding and padding > 0
    r1             = x / Game.width
    r2             = y / Game.height
    scale          = if r1 <= r2 then r1 else r2
    max_scale      = 1.0
    min_scale      = 0.4
    scale          = Math.max(min_scale, Math.min(max_scale, scale))

  update_window: ->
    return Game.scale if Game.width is null or Game.height is null
    scale = get_scale()
    tol   = .001
    return if Math.abs(Game.scale - scale) < tol # don't update after very small changes
    Game.scale = scale 
    w          = Math.ceil(Game.width * scale) + 'px'
    h          = Math.ceil(Game.height * scale) + 'px'
    @div.style('width', w).style('height', h)    
    @svg.style('width', w).style('height', h)
    @g.attr('transform', 'translate(' + scale * Game.width * 0.5 + ',' + scale * Game.height * 0.5 + ') scale(' + scale + ')' + 'translate(' + -Game.width * 0.5 + ',' + -Game.height * 0.5 + ')')
    $(document.body).css('width', w).css('height', h)
    return

  constructor: (@config = {}) ->
    @element    = [] # initialize
    @div        = d3.select("#game_div")
    @svg        = d3.select("#game_svg")
    @svg        = @div.append('svg').attr('id', 'game_svg') if @svg.empty()
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
    @update_window()

  start: -> Physics.start(@) # start all elements and associate physics engine with this game instance
    
  stop: -> Physics.stop() # stop all elements

  end: (callback = ->) -> # end the game by returning true i.e. stopping any d3 "progress" timer
    if Gameprez?
      Gameprez.end(Gamescore.value, callback)
    else 
      callback()
    return true # game over so return true to stop the d3 timer calling @progress()


  cleanup: -> # remove all elements from Collision list and set to object reference to null
    len = Collision.list.length
    while (len--) # decrementing avoids potential indexing issues after popping last element off
      element = Collision.list.pop()
      element.destroy()
      element = null