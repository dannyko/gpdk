class Root extends Circle
  constructor: (@config = {}) ->
    super
    @is_root   = true
    @fixed     = true    
    @image.attr("fill", "#FFF")
    @size      = 13
    @angle     = -Math.PI * 0.5 # initialize bullet angle
    @angleStep = 2 * Math.PI / 60 # initialize per-step angle change magnitude 
    @svg.on("mousemove", @draw) # default mouse behavior is to control the root element position
    d3.select(window).on("keydown", @keydown) # default keyboard listener
    @svg.on("mousedown", @fire) # default mouse button listener
    @svg.on("mousewheel", @spin) # default scroll wheel listener
  draw: (node = @svg.node()) =>
    xy = d3.mouse(node)
    @r.x = xy[0]
    @r.y = xy[1]
    super()
    @collision_detect()
  spin: () =>
    delta  = @angleStep * d3.event.wheelDelta / Math.abs(d3.event.wheelDelta)
    @angle = @angle - delta
  keydown: () =>
    switch d3.event.keyCode 
      when 70 then @fire() # f key fires bullets
      when 39 then @angle += @angleStep # right arrow changes firing angle by default
      when 37 then @angle -= @angleStep # left arrow changes firing angle by default
      when 38 then @fire() # up arrow fires bullet
      when 40 then @angle += Math.PI # down arrow reverses direction of firing angle 
    return
  fire: () =>
    bullet      = new Bullet()
    speed       = 10 / @dt
    x           = Math.cos(@angle)
    y           = Math.sin(@angle)
    bullet.x    = @r.x + x * (@size / 3 + bullet.size)
    bullet.y    = @r.y + y * (@size / 3 + bullet.size)
    bullet.u    = speed * x
    bullet.v    = speed * y
    bullet.n.push(n) for n in @n
    element.n.push(bullet) for element in @n
    bullet.draw()
    bullet.start()
  
  death_check: (n) ->
    d = new Vec(n.r).subtract(@r).normalize()
    bump = 0.1 / @dt
    n.v.add(d.scale(bump))

class @Circletest 
  constructor: (@config = {}) ->
    @numel    = @config.numel || 64
    @element  = [] # initialize
    @svg      = d3.select("#game_svg")
    @g        = d3.select("#game_g")
    @width    = @svg.attr("width")
    @height   = @svg.attr("height")
    @zoomTick = 0 # 5000 # ms spacing between zoom draws    
    @tzoom    = 0 # integer counter for tracking zoom timer
    @scale    = 1 # initialize zoom level
    for i in [0..@numel - 1] # create element list
      newCircle = new TestCircle()
      for j in [0..@element.length - 1] # loop over all elements and add a new Circle to their neighbor lists
        continue if not @element[j]?
        newCircle.n.push(@element[j]) # add the newly created element to the neighbor list
        @element[j].n.push(newCircle) # add the newly created element to the neighbor list
      @element.push(newCircle) # extend the array of all elements in this game
    for k in [0..Math.ceil(Math.sqrt(@element.length))] # place elements on grid
      for j in [0..Math.ceil(Math.sqrt(@element.length))]
        i = k * Math.floor(Math.sqrt(@element.length)) + j
        break if i > @element.length - 1
        @element[i].r.x = @width  * 0.5 + k   * @element[i].size * 2 + @element[i].tol - Math.ceil(Math.sqrt(@element.length)) * @element[i].size 
        @element[i].r.y = @height * 0.25 + j  * @element[i].size  * 2  + @element[i].tol
        @element[i].draw()
    @root = new Root() # default root element i.e. under user control
    for element in @element
      @root.n.push(element)
      element.n.push(@root) 
    @element.push(@root) # add the newly created root element to the array of all elements

  start: () ->
    element.start() for element in @element # start element timers
    # @zoom() # set initial zoom level for the elements to fill the available space
    # d3.timer((d) => @zoom(d)) # start the zoom timer after the element timers 