.onAttach <- function(libname, pkgname) {
  packageStartupMessage("flipsideR")
}

.onLoad <- function(libname, pkgname) {
  invisible()
}

COLORDER = c("symbol", "type", "expiry", "strike", "premium", "bid", "ask", "volume", "open.interest", "retrieved")
