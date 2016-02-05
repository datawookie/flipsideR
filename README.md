# flisideR

Scripts for working with Option Chain data from Google Finance. An Option Chain is a list of the Put and Call options on a given security for a specific maturity date.

## Installation

Installation is straightforward using the devtools package.

```R
library(devtools)
install_github("DataWookie/flipsideR")
```

## Functionality

The [quantmod](http://www.quantmod.com/) package has existing functionality for accessing option chain data.

```R
> library(quantmod)
> AAPL = getOptionChain("AAPL")
> names(AAPL)
[1] "calls" "puts" 
> head(AAPL$calls)
                    Strike  Last  Chg   Bid   Ask Vol OI
AAPL160205C00070000     70 25.71 2.06 26.95 27.25   1 53
AAPL160205C00075000     75 20.50 0.00 21.95 22.25   1  2
AAPL160205C00080000     80 15.65 1.85 16.95 17.25  75 50
AAPL160205C00085000     85 10.61 1.42 11.95 12.25 151 44
AAPL160205C00086000     86 10.72 3.47 10.95 11.25  99 52
AAPL160205C00087000     87 10.30 0.00  9.95 10.25   1  1
> head(AAPL$puts)
                    Strike Last   Chg  Bid  Ask  Vol   OI
AAPL160205P00070000   70.0 0.01  0.00 0.00 0.02   13  428
AAPL160205P00075000   75.0 0.02  0.00 0.00 0.02    2  464
AAPL160205P00080000   80.0 0.02 -0.02 0.00 0.04  156 2774
AAPL160205P00083000   83.0 0.01 -0.06 0.01 0.05  102  625
AAPL160205P00085000   85.0 0.03 -0.07 0.03 0.04 1390 2999
AAPL160205P00085500   85.5 0.05 -0.15 0.02 0.06   10  248
```

The data retrieved by flipsideR is essentially the same, but instead of returning a list of data frames with separate elements for Put and Call options, these are all consolidated in a single data frame. There's also a field indicating the time at which these data were retrieved. Since options data can be volative, this is an important feature.

```R
> library(flipsideR)
> AAPL = getOptionChain("AAPL")   
> head(AAPL)
  symbol type     expiry strike premium   bid   ask volume open.interest           retrieved
1   AAPL Call 2016-02-05     50      NA 46.95 47.25     NA             0 2016-01-31 06:03:30
2   AAPL Call 2016-02-05     55   42.05 41.95 42.25      9             0 2016-01-31 06:03:30
3   AAPL Call 2016-02-05     60      NA 36.95 37.25     NA             0 2016-01-31 06:03:30
4   AAPL Call 2016-02-05     65      NA 31.95 32.25     NA             0 2016-01-31 06:03:30
5   AAPL Call 2016-02-05     70   25.71 26.95 27.25     NA            53 2016-01-31 06:03:30
6   AAPL Call 2016-02-05     75   20.50 21.95 22.25     NA             2 2016-01-31 06:03:30
> tail(AAPL)
     symbol type     expiry strike premium   bid   ask volume open.interest           retrieved
1225   AAPL  Put 2018-01-19    155   58.30 60.15 62.50     NA            71 2016-01-31 06:03:46
1226   AAPL  Put 2018-01-19    160   63.95 64.30 66.70     NA            84 2016-01-31 06:03:46
1227   AAPL  Put 2018-01-19    165   71.75 68.95 71.35     17           197 2016-01-31 06:03:46
1228   AAPL  Put 2018-01-19    170   73.35 72.50 77.00     NA          3022 2016-01-31 06:03:46
1229   AAPL  Put 2018-01-19    175   66.55 77.30 81.35     NA            68 2016-01-31 06:03:46
1230   AAPL  Put 2018-01-19    180   88.00 82.00 86.80     NA          1074 2016-01-31 06:03:46
```
