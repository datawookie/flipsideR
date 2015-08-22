source("google-finance-options-chain.R")

AAPL = getOptionQuotes("AAPL")
MMM = getOptionQuotes("MMM")

# Does this make sense? Not having much prior experience with options, I had to think about this for a bit.
# Why would the Call options be cheap at strike prices above the underlying price and get progressively more
# expensive as the strike price gets smaller? The strike price is that at which the holder of the option has
# the right to buy the security. So, to keep things simple, suppose that a stock is currently selling at $100.
# Would you be interested in purchasing the right to buy that stock at $150? Probably not. However, what about
# the right to buy the stock at $50. That sounds a lot more interesting.

head(AAPL)
tail(AAPL)
nrow(AAPL)

library(ggplot2)
library(gridExtra)

png(file.path("fig", "open-interest-strike-price-AAPL.png"), width = 800, height = 1200)
ggplot(AAPL, aes(x = strike)) +
  geom_linerange(aes(ymin = 0, ymax = open.interest, col = type)) +
  geom_vline(xintercept = AAPL$underlying.price[1], lty = "dotted") +
  scale_colour_manual(values = c("red", "blue")) +
  xlab("Strike Price") + ylab("Open Interest") +
  facet_grid(expiry ~ type) +
  theme_classic() + theme(legend.position = "none")
dev.off()

next.expiry = min(AAPL$expiry)

g1 <- ggplot(subset(AAPL, expiry == next.expiry), aes(x = strike)) +
  geom_point(aes(y = premium, col = type)) +
  geom_vline(xintercept = AAPL$underlying.price[1], lty = "dotted") +
  xlab("") + ylab("Option Premium") +
  scale_colour_manual(values = c("red", "blue")) +
  facet_wrap(~ type) +
  theme_classic() + theme(legend.position = "none")

g2 <- ggplot(subset(AAPL, expiry == next.expiry), aes(x = strike)) +
  geom_linerange(aes(ymin = 0, ymax = open.interest / 10000, col = type)) +
  geom_vline(xintercept = AAPL$underlying.price[1], lty = "dotted") +
  xlab("Strike Price") + ylab("Open Interest (10 000)") +
  scale_colour_manual(values = c("red", "blue")) +
  facet_wrap(~ type) +
  theme_classic() + theme(legend.position = "none")

png(file.path("fig", "open-interest-premium-strike-price-AAPL.png"), width = 800, height = 800)
grid.arrange(g1, g2, ncol = 1)
dev.off()