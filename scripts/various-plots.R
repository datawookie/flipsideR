library(flipsideR)

AAPL = getOptionQuotes("AAPL")

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
