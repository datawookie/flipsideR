library(flipsideR)

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
