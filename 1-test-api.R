AAPL = getOptionQuote("AAPL")
MMM = getOptionQuote("MMM")

library(ggplot2)

png(file.path("fig", "open-interest-strike-price-AAPL.png"), width = 800, height = 1200)
ggplot(AAPL, aes(x = strike)) +
  geom_linerange(aes(ymin = 0, ymax = open.interest, col = type)) +
  geom_vline(xintercept = AAPL$underlying.price[1], lty = "dotted") +
  scale_colour_manual(values = c("red", "blue")) +
  xlab("Strike Price") + ylab("Open Interest") +
  facet_grid(expiry ~ type) +
  theme_classic() + theme(legend.position = "none")
dev.off()