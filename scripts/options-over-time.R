library(flipsideR)

# Download options data at hourly intervals and see how they change with time.
#
# In post show how the download function is changed to include the time that the data were retrieved.

library(foreach)

NDAYS <- 13
NHOURS <- NDAYS * 24

options = foreach (n = 1:NHOURS) %do% {
  if (n != 1) Sys.sleep(60*60)
  #
  timestamp = Sys.time()
  print(timestamp)
  #
  D = rbind(getOptionChain("AAPL"), getOptionChain("MSFT"), getOptionChain("ADBE"), getOptionChain("RHT"))
  write.csv(D, file = file.path("data", strftime(timestamp, "%Y%m%d-%H%M%S.csv")))
}
