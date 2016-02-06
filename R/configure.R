.onAttach <- function(libname, pkgname) {
  description = packageDescription("flipsideR")

  packageStartupMessage(description$Package, " (version ", description$Version, ") ",
                        format(eval(parse(text = description$`Authors@R`)), include = c("given", "family", "email"))
                        )
}

.onLoad <- function(libname, pkgname) {
  invisible()
}

COLORDER = c("symbol", "type", "expiry", "strike", "premium", "bid", "ask", "volume", "open.interest", "retrieved")
