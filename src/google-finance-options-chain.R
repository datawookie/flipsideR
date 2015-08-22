library(RCurl)
library(jsonlite)
library(plyr)

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

# A more direct method to fix the JSON data (making sure that all the keys are quoted). This will be a lot faster
# for large JSON packages.
#
fixJSON <- function(json) {
  gsub('([^,{:]+):', '"\\1":', json)
}

# URL templates
#
URL1 = 'http://www.google.com/finance/option_chain?q=%s%s&output=json'
URL2 = 'http://www.google.com/finance/option_chain?q=%s%s&output=json&expy=%d&expm=%d&expd=%d'

getOptionQuotes <- function(symbol, exchange = NA) {
  exchange = ifelse(is.na(exchange), "", paste0(exchange, ":"))
  #
  url = sprintf(URL1, exchange, symbol)
  #
  chain = tryCatch(fromJSON(fixJSON(getURL(url))), error = function(e) NULL)
  #
  if (is.null(chain)) stop(sprintf("retrieved document is not JSON. Try opening %s in your browser.", url))
  #
  # Iterate over the expiry dates
  #
  options = mlply(chain$expirations, function(y, m, d) {
    url = sprintf(URL2, exchange, symbol, y, m, d)
    expiry = fromJSON(fixJSON(getURL(url)))
    #
    expiry$calls$type = "Call"
    expiry$puts$type  = "Put"
    #
    prices = rbind(expiry$calls, expiry$puts)
    #
    prices$expiry = sprintf("%4d-%02d-%02d", y, m, d)
    prices$underlying.price = expiry$underlying_price
    #
    prices$retrieved = Sys.time()
    #
    prices
  })
  #
  options = options[sapply(options, class) == "data.frame"]
  #
  # Concatenate data for all expiration dates and add in symbol column
  #
  options = cbind(data.frame(symbol), rbind.fill(options))
  #
  options = rename(options, c("p" = "premium", "b" = "bid", "a" = "ask", "oi" = "open.interest"))
  #
  for (col in c("strike", "premium", "bid", "ask")) options[, col] = suppressWarnings(as.numeric(options[, col]))
  options[, "open.interest"] = suppressWarnings(as.integer(options[, "open.interest"]))
  #
  options[, c("symbol", "type", "expiry", "strike", "premium", "bid", "ask", "open.interest", "retrieved")]
}