library(RCurl)
library(jsonlite)

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

# A more direct method to fix the JSON data (making sure that all the keys are quoted)
#
fixJSON <- function(json){
  gsub("([\\{,]+)([^: ]*):", '\\1"\\2":', json)
}

getOptionQuote <- function(symbol){
  # output = list()
  url = sprintf('http://www.google.com/finance/option_chain?q=%s&output=json', symbol)
  chain = getURL(url)
  fix = fixJSON(chain)
  json = fromJSON(fix)
  numExp = dim(json$expirations)[1]
  for(i in 1:numExp){
    # download each expirations data
    y = json$expirations[i,]$y
    m = json$expirations[i,]$m
    d = json$expirations[i,]$d
    expName = paste(y, m, d, sep = "_")
    if (i > 1){
      url = paste('http://www.google.com/finance/option_chain?q=', symbol, '&output=json&expy=', y, '&expm=', m, '&expd=', d, sep = "")
      json = fromJSON(fixJSON(getURL(url)))
    }
    output[[paste(expName, "calls", sep = "_")]] = json$calls
    output[[paste(expName, "puts", sep = "_")]] = json$puts
  }
  return(output)
}

aapl_opt = getOptionQuote("AAPL")

plot(aapl_opt$"2015_4_17_puts"$strike, aapl_opt$"2015_4_17_puts"$oi, type = "s", main = "Open Interest by Strike")