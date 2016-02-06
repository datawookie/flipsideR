# TODO: Add column for exchange in data.

# TODO: Trying to avoid using dplyr and plyr. Right now dplyr is just being used for soring in a magrittr chain. Ideally
# I would like to move across to dplyr completely but I don't see an equivalent to mlply().

# Initial version of this code based on http://mktstk.wordpress.com/2014/12/29/start-trading-like-a-quant-download-option-chains-from-google-finance-in-r/

# A more direct method to fix the JSON data (making sure that all the keys are quoted). This will be a lot faster
# for large JSON packages.
#
fixJSON <- function(json) {
	gsub('([^,{:]+):', '"\\1":', json)
}

# AUSTRALIAN OPTIONS --------------------------------------------------------------------------------------------------

# ASX is the Australian Securities Exchange.

URLASX = 'http://www.asx.com.au/asx/markets/optionPrices.do?by=underlyingCode&underlyingCode=%s&expiryDate=&optionType=B'

#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_table
#' @import magrittr
getOptionChainAsx <- function(symbol) {
  url = sprintf(URLASX, symbol)

  html <- read_html(url)

  # Use the second element in the list (the first element gives data on the underlying stock)
  #
  options = (html %>% html_nodes("table.options") %>% html_table(header = TRUE))[[2]] %>%
    rename(c("Bid" = "bid", "Offer" = "ask", "Openinterest" = "open.interest", "Volume" = "volume", "Expirydate" = "expiry",
             "P/C" = "type", "Margin Price" = "premium", "Exercise" = "strike")) %>%
    transform(
      symbol        = symbol,
      retrieved     = Sys.time(),
      open.interest = suppressWarnings(as.integer(gsub(",", "", open.interest))),
      premium       = suppressWarnings(as.numeric(premium)),
      bid           = suppressWarnings(as.numeric(bid)),
      ask           = suppressWarnings(as.numeric(ask)),
      volume        = suppressWarnings(as.integer(gsub(",", "", volume))),
      expiry        = as.Date(expiry, format = "%d/%m/%Y")
    ) %>% dplyr::arrange(type, strike)
  options[, COLORDER]
}

# ---------------------------------------------------------------------------------------------------------------------

# URL templates
#
URL1 = 'http://www.google.com/finance/option_chain?q=%s%s&output=json'
URL2 = 'http://www.google.com/finance/option_chain?q=%s%s&output=json&expy=%d&expm=%d&expd=%d'

#' Retrieve options dataAAPL.
#'
#' @param symbol A ticker symbol.
#' @param exchange The exchange on which symbol is listed.
#' @return A data frame with the required options.
#' @examples
#' getOptionChain("AAPL")
#' getOptionChain("MSFT", "NASDAQ")
#' @importFrom jsonlite fromJSON
#' @importFrom plyr mlply rbind.fill rename
#' @importFrom RCurl getURL
#' @export
getOptionChain <- function(symbol, exchange = NA) {
  exchange = toupper(exchange)
  #
  if (exchange == "ASX") return(getOptionChainAsx(symbol))
  #
	exchange = ifelse(is.na(exchange), "", paste0(exchange, ":"))
	#
	url = sprintf(URL1, exchange, symbol)
	#
	chain = tryCatch(fromJSON(fixJSON(getURL(url))), error = function(e) NULL)
	#
	if (is.null(chain)) stop(sprintf("Retrieved document is not JSON. Try opening %s in your browser.", url))
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
		prices = rbind.fill(expiry$calls, expiry$puts)
		#
		prices$expiry = sprintf("%4d-%02d-%02d", y, m, d)
		prices$underlying.price = expiry$underlying_price
		#
		prices$retrieved = Sys.time()
		#
		prices
	})
	#
	# Filter out dates with data
	#
	options = options[sapply(options, class) == "data.frame"]
	#
	# Concatenate data for all expiration dates and add in symbol column
	#
	options = cbind(data.frame(symbol), rbind.fill(options))
	#
	options = rename(options, c("p" = "premium", "b" = "bid", "a" = "ask", "oi" = "open.interest", "vol" = "volume"))
	#
	for (col in c("strike", "premium", "bid", "ask")) options[, col] = suppressWarnings(as.numeric(options[, col]))
	options[, "open.interest"] = suppressWarnings(as.integer(options[, "open.interest"]))
	options[, "volume"]        = suppressWarnings(as.integer(options[, "volume"]))
	#
	options[, COLORDER]
}
