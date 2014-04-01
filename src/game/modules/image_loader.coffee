class @ImageLoader # module for managing image assets
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
	  else
	    @loadingStats.count++

	@preload: (imageList, callback) -> # class method; cache dictionary builder
	  @loadingStats.total = imageList.length
	  @loadingStats.count = 0
	  @loadingStats.cb    = callback
	  for url in imageList
	    @load(url)