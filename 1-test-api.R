AAPL = getOptionQuote("AAPL")
MMM = getOptionQuote("MMM")

library(ggplot2)

png(file.path("fig", "open-interest-strike-price-AAPL.png"), width = 800, height = 1200)
ggplot(AAPL, aes(x = strike)) +
  geom_linerange(aes(ymin = 0, ymax = open.interest), col = "blue") +
  xlab("Strike Price") + ylab("Open Interest") +
  facet_grid(expiry ~ .) +
  theme_classic()
dev.off()