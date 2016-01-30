library(stringr)
library(options)

context("Test downloading of options quotes")

test_that("retrieving options gives right data type", {
  AAPL = getOptionQuotes("AAPL")
  expect_equal(class(AAPL), "data.frame")
  expect_equal(ncol(AAPL), 10)
})

test_that("fails for (wrong) specific exchange", {
  AAPL = tryCatch(getOptionQuotes("AAPL", "NYSE"), error = function(e) 1)
  expect_equal(AAPL, 1)
})

# Other options that could be used here:
#
# CVX | NYSE
# BA  | NYSE
# WMT | NYSE
#
test_that("succeeds for (right) specific exchange", {
  MSFT = getOptionQuotes("MSFT", "NASDAQ")
  expect_equal(class(MSFT), "data.frame")
})
