class ImageLoader # module for managing image assets
  
  @loading: false # initialize boolean to prevent duplicate preload() calls
  @cache: {} # class variable; initialize cache dictionary object
  @loadingStats: {total: null, count: null, finalCallback: null} # class variable, initialize loading statistics object

  @load: (url) -> # class method; callback incrementor - wait until final image is loaded before executing callback
	  if @cache[url]?
	    @callbackHandler()
	  else
	    img         = new Image()
	    img.onload  = ImageLoader.callbackHandler
	    img.src     = url
	    @cache[url] = img
	  img # return image object

  @callbackHandler: ->
    ImageLoader.loadingStats.count++
    if ImageLoader.loadingStats.count is ImageLoader.loadingStats.total
      ImageLoader.loadingStats.finalCallback() # execute the final callback
      ImageLoader.loading = false
    return

  @preload: (imageList, callback) -> # class method; cache dictionary builder
	  return if @loading # prevent duplicate calls
	  @loading = true
	  @loadingStats.total         = imageList.length
	  @loadingStats.count         = 0 # initialize
	  @loadingStats.finalCallback = callback
	  @load(url) for url in imageList
	  return	  