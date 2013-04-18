class @Rectangle extends Element

  # Simple Rectangle element
  constructor: (@config = {}) ->
    super
    @type  = 'Rectangle'
    @posx  = @config.x || '0'
    @posy  = @config.y || '0'
    @width = @config.width || '10'
    @height = @config.height || '5'
    @stroke = @config.stroke || @_stroke
    @_fill = @config.fill || "#FFF"
    # Call the draw fuction to allow svg or canvas
    @draw()

  # Set methods to update rect params
  setX: (xpos) ->
    if xpos
      @posx = xpos

  setY: (ypos) ->
    if ypos
      @posy = ypos

  setWidth: (width) ->
    if width
        @width = width

  setHeight: (height) ->
    if height
        @height = height

  setFill: (fill) ->
    if fill
        @_fill = fill

  # Get methods to check rect params
  getX:->
    @posx
    
  getY: ->
    @posy

  getWidth:->
    @width 

  getHeight:->
    @height

  getFill:->
    @_fill
  
  draw:->
    super
    # if using svg engine draw. Might need a better check
    if @svg
        # Defualt draw if no image.
        if not @image
            @image = @g.append("rect")
            @image.attr("stroke", @_stroke)
            @image.attr("fill", "#FFF")
            @image.attr("x", @posx)
            @image.attr("y", @posy)
            @image.attr("height", @height)
            @image.attr("width", @width)
            @image.attr("fill", "#FFF")
    # if canvas engine draw 
    #else @canvas etc



    



        


