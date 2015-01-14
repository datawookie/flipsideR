library(RCurl)
library(jsonlite)
library(plyr)

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

# A more direct method to fix the JSON data (making sure that all the keys are quoted). This will be a lot faster
# for large JSON packages.
#
fixJSON <- function(json){
  gsub('([^,{:]+):', '"\\1":', json)
}

# URL templates
#
URL1 = 'http://www.google.com/finance/option_chain?q=%s&output=json'
URL2 = 'http://www.google.com/finance/option_chain?q=%s&output=json&expy=%d&expm=%d&expd=%d'

getOptionQuotes <- function(symbol){
  url = sprintf(URL1, symbol)
  #
  chain = fromJSON(fixJSON(getURL(url)))
  #
  # Iterate over the expiry dates
  #
  options = mlply(chain$expirations, function(y, m, d) {
    url = sprintf(URL2, symbol, y, m, d)
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
  # Concatenate data for all expiration dates and add in symbol column
  #
  options = cbind(data.frame(symbol), rbind.fill(options))
  #
  names(options)[c(6, 10, 11, 12)] = c("premium", "bid", "ask", "open.interest")
  #
  for (col in c("strike", "premium", "bid", "ask")) options[, col] = as.numeric(options[, col])
  options[, "open.interest"] = suppressWarnings(as.integer(options[, "open.interest"]))
  #
  options[, c(1, 16, 15, 6, 10, 11, 17, 14, 12, 18)]
}