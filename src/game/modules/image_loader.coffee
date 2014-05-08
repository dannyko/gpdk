class $z.ImageLoader # module for managing image assets
  
  @loading: false # initialize boolean to prevent duplicate preload() calls
  @cache: {} # class $z.variable; initialize cache dictionary object
  @loadingStats: {total: null, count: null, finalCallback: null} # class $z.variable, initialize loading statistics object

  @load: (url) -> # class $z.method; callback incrementor - wait until final image is loaded before executing callback
	  if @cache[url]?
	    @callbackHandler()
	  else
	    img         = new Image()
	    img.onload  = $z.ImageLoader.callbackHandler
	    img.src     = url
	    @cache[url] = img
	  img # return image object

  @callbackHandler: ->
    $z.ImageLoader.loadingStats.count++
    if $z.ImageLoader.loadingStats.count is $z.ImageLoader.loadingStats.total
      $z.ImageLoader.loadingStats.finalCallback() # execute the final callback
      $z.ImageLoader.loading = false
    return

  @preload: (imageList, callback) -> # class $z.method; cache dictionary builder
	  return if @loading # prevent duplicate calls
	  @loading = true
	  @loadingStats.total         = imageList.length
	  @loadingStats.count         = 0 # initialize
	  @loadingStats.finalCallback = callback
	  @load(url) for url in imageList
	  return	  