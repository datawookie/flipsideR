library(RCurl)
library(jsonlite)
library(plyr)

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

# A more direct method to fix the JSON data (making sure that all the keys are quoted). This will be a lot faster
# for large JSON packages.
#
fixJSON <- function(json){
  gsub("([\\{,]+)([^: ]*):", '\\1"\\2":', json)
}

# URL templates
#
URL1 = 'http://www.google.com/finance/option_chain?q=%s&output=json'
URL2 = 'http://www.google.com/finance/option_chain?q=%s&output=json&expy=%d&expm=%d&expd=%d'

getOptionQuote <- function(symbol){
  url = sprintf(URL1, symbol)
  #
  chain = fromJSON(fixJSON(getURL(url)))
  #
  # Under what conditions do we need to exclude first row here using [-1,]????
  # Under what conditions do we need to exclude first row here using [-1,]????
  # Under what conditions do we need to exclude first row here using [-1,]????
  # Under what conditions do we need to exclude first row here using [-1,]????
  # Under what conditions do we need to exclude first row here using [-1,]????
  # Under what conditions do we need to exclude first row here using [-1,]????
  # Under what conditions do we need to exclude first row here using [-1,]????
  #
  options = mlply(chain$expirations, function(y, m, d) {
    url = sprintf(URL2, symbol, y, m, d)
    expiry = fromJSON(fixJSON(getURL(url)))
    #
    expiry$calls$type = "call"
    expiry$puts$type  = "put"
    #
    prices = rbind(expiry$calls, expiry$puts)
    #
    prices$expiry = sprintf("%4d-%02d-%02d", y, m, d)
    #
    prices[, c("expiry", "type", "strike", "oi")]
  })
  #
  # Concatenate data for all expiration dates and add in symbol column
  #
  options = cbind(data.frame(symbol), rbind.fill(options))
  #
  options[,4] = as.numeric(options[,4])
  options[,5] = suppressWarnings(as.integer(options[,5]))
  #
  names(options)[5] = "open.interest"
  #
  options
}
aapl_opt = getOptionQuote("AAPL")