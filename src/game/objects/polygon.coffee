class @Polygon extends Element # simplest path-based shape by default involving 3 straight line segments
  constructor: (@config = {}) ->
    super
    path   = # use an equilateral triangle as the default polygonal shape
      [
        {pathSegTypeAsLetter: 'M', x: -@size, y: 2 * @size / 3, react: true},
        {pathSegTypeAsLetter: 'L', x: 0, y: -Math.sqrt(3) * @size + 1 * @size / 3, react: true},
        {pathSegTypeAsLetter: 'L', x: @size, y: 2 * @size / 3, react: true},
        {pathSegTypeAsLetter: 'Z'} # close the path by default
      ]
    @path  = @config.path || path
    @type  = 'Polygon'
    @image = @g.append("path")
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)
    
  d: ->
    Utils.d(@path)