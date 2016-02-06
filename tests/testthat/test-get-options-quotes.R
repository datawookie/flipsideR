library(flipsideR)

# TODO:
#
# Explore other ways to get option data from Google Finance. For example, opening the URL
#
# https://www.google.com/finance/option_chain?q=NYSE:CVX
#
# gives the put/call options in a HTML page. We could parse this, which would be quicker... Does it give us the
# same level of detail in the data?

# TODO: USE THIS!!
#
# Does this make sense? Not having much prior experience with options, I had to think about this for a bit.
# Why would the Call options be cheap at strike prices above the underlying price and get progressively more
# expensive as the strike price gets smaller? The strike price is that at which the holder of the option has
# the right to buy the security. So, to keep things simple, suppose that a stock is currently selling at $100.
# Would you be interested in purchasing the right to buy that stock at $150? Probably not. However, what about
# the right to buy the stock at $50. That sounds a lot more interesting.

context("Test download of options data.")

test_that("retrieving options gives right data type", {
  AAPL = getOptionChain("AAPL")
  expect_equal(class(AAPL), "data.frame")
  expect_equal(ncol(AAPL), 10)
})

test_that("fails for (wrong) specific exchange", {
  AAPL = tryCatch(getOptionChain("AAPL", "NYSE"), error = function(e) 1)
  expect_equal(AAPL, 1)
})

# Dave Peterson <davep865@gmail.com> noted that when he requested data for "CVX" he would get an
# error. It turned out that issue here was that he was based in Canada and Google was looking at
# a stock on the Canadian stock exchange with the same symbol (and which did not have options).
# To resolve this issue he found that specifying NYSE:CVX rather than just CVX worked. This is what
# motivated the inclusion of exchange as an option.
#
# Other options that could be used here:
#
# CVX | NYSE
# BA  | NYSE
# WMT | NYSE
#
test_that("succeeds for (right) specific exchange", {
  MSFT = getOptionChain("MSFT", "NASDAQ")
  expect_equal(class(MSFT), "data.frame")
})

# These are some of the more active options on ASX: CBA, NAB, WBC, BHP and RIO.
#
test_that("retrieves ASX options", {
  OZL = getOptionChain("OZL", "ASX")
})
