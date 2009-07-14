.pcCache <- raw(2^20)
.pcIdx <- 1
.pcUDB <- NULL
.getHookOld <- base::getHook

.onAttach <- function(library,pkg){
	unlockBinding('.pcCache',asNamespace('PopCon'))
	unlockBinding('.pcIdx',asNamespace('PopCon'))
	unlockBinding('.pcUDB',asNamespace('PopCon'))
	unlockBinding('.getHookOld',asNamespace('PopCon'))

	# Trace package loading
	getHookNew <- function(hookName){
		hooks <- list()
		if (exists(hookName, envir = .userHooksEnv, inherits = FALSE))
			hooks <- get(hookName, envir = .userHooksEnv, inherits = FALSE)
		if (length(grep('onLoad',hookName)) > 0)
			hooks <- c(hooks,function(pkg,lib)PopCon::updateCache(paste('package',pkg,sep=':')))
		hooks
	}
	environment(getHookNew) <- asNamespace('base')
	unlockBinding('getHook',asNamespace('base'))
	assign('getHook',getHookNew,asNamespace('base'))
	lockBinding('getHook',asNamespace('base'))

	# Attach database just after PopCon
	.pcUDB <<- initPopCon(updateCache)
	attach(.pcUDB,pos=which(search() %in% 'package:PopCon')+1,name='.pcUDB')
}

.Last.lib <- function(library,pkg){
	detach('.pcUDB')
	unlockBinding('getHook',asNamespace('base'))
	assign('getHook',PopCon:::.getHookOld,asNamespace('base'))
	lockBinding('getHook',asNamespace('base'))
}

`activatePopCon`   <- function() .Call('activate_popcon', TRUE,PACKAGE='PopCon')
`deactivatePopCon` <- function() .Call('activate_popcon',FALSE,PACKAGE='PopCon')

`clearCache` <- function(){
	deactivatePopCon()
	.pcCache[1:length(.pcCache)] <<- as.raw(0)
	.pcIdx <<- 1
	activatePopCon()
}


`updateCache` <- function(symbol){
	deactivatePopCon()
	symbol <- charToRaw(symbol)
	if ((.pcIdx + length(symbol)) > length(.pcCache)) {
		sendCache()
		clearCache()
	}
	.pcCache[.pcIdx:(.pcIdx+length(symbol)-1)] <<- symbol
	.pcIdx <<- .pcIdx + length(symbol) + 1
	activatePopCon()
}

`getCache` <- function(){
	deactivatePopCon()
	x <- unname(
			sapply(
				split(.pcCache[.pcCache!=as.raw(0)],
				cumsum(.pcCache==as.raw(0))[.pcCache!=as.raw(0)]),
				rawToChar
			)
		)
	activatePopCon()
	x
}

`initPopCon` <- function(symHandler){
	.pcUDB <<- .Call('init_popcon',symHandler,PACKAGE='PopCon')
}

`sendCache` <- function(){}

# Disabled for now.
#`sendCache` <- function(){
#	deactivatePopCon()
#	x <- serialize(.pcCache,NULL)
#
#	httpPost <- charToRaw(
#'POST /PopCon jHTTP/1.1\r
#Host: localhost\r
#User-Agent: PopCon/0.1 \r
#Connection: close\r
#Content-Type: multipart/form-data; boundary=--928340934\r
#Content-Length: ')
#
#	mime <- charToRaw(
#'----928340934\r
#Content-Disposition: form-data; name="PopConFile"; filename="PopCon.Rdata"\r
#Content-Type: application/octet-stream\r
#\r
#')
#	mime <- append(mime,x)
#	mime <- append(mime,charToRaw('\r\n----928340934--\r\n'))
#
#	httpPost <- append(httpPost,charToRaw(as.character(length(mime))))
#	httpPost <- append(httpPost,charToRaw('\r\n\r\n'))
#	httpPost <- append(httpPost,mime)
#
#	con <- socketConnection('localhost',80,blocking=TRUE,open='a+b')
#	writeBin(httpPost,con)
#	ret <- readLines(con)
#	close(con)
#	activatePopCon()
#	invisible(ret)
#}
