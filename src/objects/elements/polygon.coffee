class @Polygon extends Element # simplest path-based shape by default involving 3 straight line segments
  constructor: (@config = {}) ->
    super
    @type    = 'Polygon'
    @path    = @config.path || null
    @image   = @g.append("path")
    @image.attr("stroke", @_stroke)
    @image.attr("fill", @_fill)

  path = # use a triangle as the default type of polygonal shape
    [
      {pathSegTypeAsLetter: 'M', x: -@size, y: 2 * @size / 3, react: true},
      {pathSegTypeAsLetter: 'L', x: 0, y: -Math.sqrt(3) * @size + 1 * @size / 3, react: true},
      {pathSegTypeAsLetter: 'L', x: @size, y: 2 * @size / 3, react: true},
      {pathSegTypeAsLetter: 'Z'} # close the path by default
    ]  

  d: ->
    (Utils.path_seg(p) for p in @path).join(" ")