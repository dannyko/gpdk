class $z.Game
  
  @width:  null # class $z.variable for easy access from other objects
  @height: null # class $z.variable for easy access from other objects
  @scale:  1 # class $z.variable for global scaling transformations
  @audioSwitch: true
  @musicSwitch: true
  @instance: null
  @message_color: "#FFF"
  @width: 800 # default 'natural' width for the game (sets aspect ratio)
  @height: 600 # default 'natural' height for the game (sets aspect ratio) ### parseInt(@svg.attr("height"), 10)
  @maxdim: Math.max(@width, @height)
  
  constructor: (@config = {}) ->
    @images_loaded  = false # initialize
    @element    = [] # initialize
    @div        = d3.select("#game_div")
    @svg        = d3.select("#game_svg")
    @svg        = @div.append('svg').attr('id', 'game_svg') if @svg.empty()
    @svg.attr("viewBox", '0 0 ' + $z.Game.width + ' ' + $z.Game.height)
      .attr("preserveAspectRatio", "xMidYMin meet")
      .attr('width', 100 * $z.Game.width / $z.Game.maxdim + '%')
      .attr('height', 100 * $z.Game.height / $z.Game.maxdim + '%')
    @scale      = 1 # initialize zoom level (implementation still pending)
    @g          = d3.select("#game_g")
    @g          = @svg.append('g') if @g.empty()
    @g.attr('id', 'game_g')
    $z.Game.instance = @ # associate class $z.variable with this instance for global accessibility from any context
    $z.Game.instance.div.style('opacity', 0)
    @preload_images()

  image_preload_callback = -> # default callback function (private)
    $z.Game.instance.images_loaded = true
    $z.Game.instance.start()
    dur = 1000
    $z.Game.instance.div.transition()
      .duration(dur)
      .style('opacity', 1)    

  preload_images: (image_list = $z.Game.instance.image_list, preload_callback) -> 
    if image_list? and image_list.length? and image_list.length > 0
      $z.ImageLoader.preload(image_list, image_preload_callback)
    else
      dur = 1000
      $z.Game.instance.div.transition()
        .duration(dur)
        .style('opacity', 1)    

  current_width = (padding = 8) ->
    element   = window.top.document.body # .getElementsByTagName('iframe')[0]
    x = $(element).width()
    x = Math.min(x, $(window).width())
    x = Math.min(x, $(window.top).width())
    x = (x - padding) if x > padding and padding > 0  

  current_height = (padding = 124) ->
    element = window.top # .getElementsByTagName('iframe')[0]
    y = $(element).height()
    y = (y - padding) if y > padding and padding > 0 # account for top bar, footer, and spacing
    y

  get_scale = -> # minimal padding to prevent browser scrollbar issues 
    r1        = current_width() / $z.Game.width
    r2        = current_height() / $z.Game.height
    scale     = if r1 <= r2 then r1 else r2
    max_scale = 1.0
    min_scale = 0.39
    scale     = Math.max(min_scale, Math.min(max_scale, scale))

  start: -> 
    $z.Physics.start() # start all elements and associate physics engine with this game instance
    Gameprez?.start()
    return
    
  stop: (callback = ->) -> 
    @cleanup()
    $z.Physics.stop() # stop all elements and decouple them from the Physics engine
    if Gameprez?
      Gameprez.end($z.Gamescore.value, callback)
    else 
      callback()
    return

  cleanup: -> # remove all elements from Collision list and set to object reference to null
    @g.selectAll('g').each (d) -> d?.remove()
    return

  message: (txt, callback, dur = 1000) ->
    callback ||= ->
    @g.selectAll('.game_message').remove()
    spacing = 10 
    ready = @g.append("text")
      .attr('class', 'game_message')
      .text(txt)
      .attr("stroke", "none")
      .attr("fill", $z.Game.message_color)
      .attr("font-size", "36")
      .attr("x", $z.Game.width  / 2 - txt.length * spacing)
      .attr("y", $z.Game.height / 2 + 20)
      .attr('font-family', 'arial')
      .attr('font-weight', 'bold')
      .attr('opacity', 0)
      .transition()
      .duration(dur)
      .style("opacity", 1)
      .transition()
      .duration(dur)
      .style('opacity', 0)
      .remove()
      .each('end', callback)
    return