class @Game
  
  ## class variables:
  @width:  null # class variable for easy access from other objects
  @height: null # class variable for easy access from other objects
  @scale:  1 # class variable for global scaling transformations
  
  current_width = (padding = 8) ->
    element   = window.top.document.body # .getElementsByTagName('iframe')[0]
    x = $(element).width()
    x = Math.min(x, $(window).width())
    x = Math.min(x, $(window.top).width())
    x = (x - padding) if x > padding and padding > 0  

  current_height = (padding = 8) ->
    element   = window.top.document.body # .getElementsByTagName('iframe')[0]
    y = $(element).height()
    y = Math.min(y, $(window).height())
    y = Math.min(y, $(window.top).height())
    y = (y - padding) if y > padding and padding > 0

  get_scale = -> # minimal padding to prevent browser scrollbar issues 
    r1        = current_width() / Game.width
    r2        = current_height() / Game.height
    scale     = if r1 <= r2 then r1 else r2
    max_scale = 1.0
    min_scale = 0.39
    scale     = Math.max(min_scale, Math.min(max_scale, scale))

  update_window: (force = false) ->
    return Game.scale if Game.width is null or Game.height is null
    scale = get_scale()
    tol   = .001
    unless force
      return if Math.abs(Game.scale - scale) < tol # don't update after very small changes
    Game.scale = scale 
    w          = Math.ceil(Game.width * scale) + 'px'
    h          = Math.ceil(Game.height * scale) + 'px'
    @div.style('width', w).style('height', h)    
    @svg.style('width', w).style('height', h)
    @g.attr('transform', 'translate(' + scale * Game.width * 0.5 + ',' + scale * Game.height * 0.5 + ') scale(' + scale + ')' + 'translate(' + -Game.width * 0.5 + ',' + -Game.height * 0.5 + ')')
    $(document.body).css('width', w).css('height', h)
    return

  preload_images: (image_list) ->
    callback = (image) =>
       image_list.pop()
       if image_list.length > 0
         $.preloadImage( image_list[image_list.length - 1], callback )
       else
         @run()
    $.preloadImage( image_list[list.length - 1], callback)

  constructor: (@config = {}) ->
    @element    = [] # initialize
    @div        = d3.select("#game_div")
    @svg        = d3.select("#game_svg")
    @svg        = @div.append('svg').attr('id', 'game_svg') if @svg.empty()
    Game.width  = 800 # default 'natural' width for the game (sets aspect ratio)
    Game.height = 600 # default 'natural' height for the game (sets aspect ratio) ### parseInt(@svg.attr("height"), 10)
    @scale      = 1 # initialize zoom level (implementation still pending)
    @g          = d3.select("#game_g")
    @g          = @svg.append('g') if @g.empty()
    @g.attr('id', 'game_g')
	    .attr('width', @svg.attr('width'))
	    .attr('height', @svg.attr('height'))
	    .style('width', '')
	    .style('height', '')
    @update_window(force = true)
    # extend jQuery:
    ( ($) -> # image preload with callbacks using jQuery, taken from: http://designdotworks.blogspot.com/2009/05/jquery-image-preloading-with-callbacks.html?showComment=1391404596835#c6592061457251911304
     $.extend(jQuery, {  
       preloadImage: (src, callback) ->
         i = new Image() 
         f = false
         i.onload = ->  
           f = true  
           unless callback is undefined
             callback(this) 
           $(this).remove()   
         if not f
           $(i).attr('src', src).css({  
             position: 'absolute',  
             display: 'none',  
             width: 1,  
             height: 1  
           }).appendTo(document.body)
     })
    )(jQuery)

  start: -> Physics.start(@) # start all elements and associate physics engine with this game instance
    
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
      sound = false # no sound for cleanup
      element.destroy(sound)
      element = null