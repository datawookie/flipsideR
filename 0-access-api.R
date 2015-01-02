library(RCurl)
library(jsonlite)

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

getOptionQuote <- function(symbol){
  output = list()
  url = paste('http://www.google.com/finance/option_chain?q=', symbol, '&output=json', sep = "")
  x = getURL(url)
  fix = fixJSON(x)
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

fixJSON <- function(json_str){
  stuff = c('cid','cp','s','cs','vol','expiry','underlying_id','underlying_price',
            'p','c','oi','e','b','strike','a','name','puts','calls','expirations',
            'y','m','d')
  
  for(i in 1:length(stuff)){
    replacement1 = paste(',"', stuff[i], '":', sep = "")
    replacement2 = paste('\\{"', stuff[i], '":', sep = "")
    regex1 = paste(',', stuff[i], ':', sep = "")
    regex2 = paste('\\{', stuff[i], ':', sep = "")
    json_str = gsub(regex1, replacement1, json_str)
    json_str = gsub(regex2, replacement2, json_str)
  }
  return(json_str)
}

aapl_opt = getOptionQuote("AAPL")

plot(aapl_opt$"2015_4_17_puts"$strike, aapl_opt$"2015_4_17_puts"$oi, type = "s", main = "Open Interest by Strike")