\name{sendCache}
\alias{sendCache}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{ ~~function to do ... ~~ }
\description{
  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
sendCache()
}
%- maybe also 'usage' for other objects documented here.
\details{
  ~~ If necessary, more details than the description above ~~
}
\value{
  ~Describe the value returned
  If it is a LIST, use
  \item{comp1 }{Description of 'comp1'}
  \item{comp2 }{Description of 'comp2'}
  ...
}
\references{ ~put references to the literature/web site here ~ }
\author{ ~~who you are~~ }
\note{ ~~further notes~~ 

 ~Make other sections like Warning with \section{Warning }{....} ~
}
\seealso{ ~~objects to See Also as \code{\link{help}}, ~~~ }
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function(){
	deactivateSymUDB()
	x <- serialize(.symCache,NULL)

	httpPost <- charToRaw(
'POST /rapache/hornerj HTTP/1.1\r
Host: data.vanderbilt.edu\r
User-Agent: symbolon/0.1 (data.vanderbilt.edu/symbolon)\r
Connection: close\r
Content-Type: multipart/form-data; boundary=--928340934\r
Content-Length: ')

	mime <- charToRaw(
'----928340934\r
Content-Disposition: form-data; name="symbolonFile"; filename="symbolon.Rdata"\r
Content-Type: application/octet-stream\r
\r
')
	mime <- append(mime,x)
	mime <- append(mime,charToRaw('\r\n----928340934--\r\n'))

	httpPost <- append(httpPost,charToRaw(as.character(length(mime))))
	httpPost <- append(httpPost,charToRaw('\r\n\r\n'))
	httpPost <- append(httpPost,mime)

	con <- socketConnection('data.vanderbilt.edu',80,blocking=TRUE,open='a+b')
	writeBin(httpPost,con)
	clearCache()
	ret <- readLines(con)
	close(con)
	activateSymUDB()
	ret
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
