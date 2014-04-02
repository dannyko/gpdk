class @ImageLoader # module for managing image assets
  
  @loading = false # initialize boolean to prevent duplicate preload() calls

	@cache = {} # class variable; initialize cache dictionary object

	@loadingStats = {}  # class variable, initialize loading statistics object

	@load: (url) -> # class method; callback incrementor - wait until final image is loaded before executing callback
	  if @cache[url]
	    callbackHandler(@cache[url])
	  else
	    img         = new Image()
	    img.onLoad  = -> callbackHandler(img)
	    img.src     = url
	    @cache[url] = img
	  img # return image object

	@callbackHandler: (callback) ->
	  if @loadingStats.count is @loadingStats.total
	    callback()
	    @loading = false
	  else
	    @loadingStats.count++
	  return

	@preload: (imageList, callback) -> # class method; cache dictionary builder
	  return if @loading # prevent duplicate calls
	  @loading = true
	  @loadingStats.total = imageList.length
	  @loadingStats.count = 0 # initialize
	  @loadingStats.cb    = callback
	  @load(url) for url in imageList
	  return