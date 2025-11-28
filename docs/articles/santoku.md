# Introduction to santoku

### Introduction

Santoku is a package for cutting data into intervals. It provides
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md), a
replacement for base R’s [`cut()`](https://rdrr.io/r/base/cut.html)
function, as well as several convenience functions to cut different
kinds of intervals.

To install santoku, run:

``` r
install.packages("santoku")
```

### Basic usage

Use [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
like [`cut()`](https://rdrr.io/r/base/cut.html), to cut numeric data
into intervals between a set of `breaks`.

``` r
library(santoku)

x <- runif(10, 0, 10)
(chopped <- chop(x, breaks = 0:10))
#>  [1] [4, 5)  [8, 9)  [3, 4)  [4, 5)  [7, 8)  [9, 10] [6, 7)  [8, 9)  [1, 2) 
#> [10] [4, 5) 
#> Levels: [1, 2) [3, 4) [4, 5) [6, 7) [7, 8) [8, 9) [9, 10]
data.frame(x, chopped)
#>        x chopped
#> 1  4.978  [4, 5)
#> 2  8.970  [8, 9)
#> 3  3.392  [3, 4)
#> 4  4.677  [4, 5)
#> 5  7.057  [7, 8)
#> 6  9.708 [9, 10]
#> 7  6.714  [6, 7)
#> 8  8.377  [8, 9)
#> 9  1.086  [1, 2)
#> 10 4.495  [4, 5)
```

[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
returns a factor.

If data is beyond the limits of `breaks`, they will be extended
automatically:

``` r
chopped <- chop(x, breaks = 3:7)
data.frame(x, chopped)
#>        x    chopped
#> 1  4.978     [4, 5)
#> 2  8.970 [7, 9.708]
#> 3  3.392     [3, 4)
#> 4  4.677     [4, 5)
#> 5  7.057 [7, 9.708]
#> 6  9.708 [7, 9.708]
#> 7  6.714     [6, 7)
#> 8  8.377 [7, 9.708]
#> 9  1.086 [1.086, 3)
#> 10 4.495     [4, 5)
```

To chop a single number into a separate category, put the number twice
in `breaks`:

``` r
x_fives <- x
x_fives[1:5] <- 5
chopped <- chop(x_fives, c(2, 5, 5, 8))
data.frame(x_fives, chopped)
#>    x_fives    chopped
#> 1    5.000        {5}
#> 2    5.000        {5}
#> 3    5.000        {5}
#> 4    5.000        {5}
#> 5    5.000        {5}
#> 6    9.708 [8, 9.708]
#> 7    6.714     (5, 8)
#> 8    8.377 [8, 9.708]
#> 9    1.086 [1.086, 2)
#> 10   4.495     [2, 5)
```

To quickly produce a table of chopped data, use
[`tab()`](https://hughjonesd.github.io/santoku/reference/chop.md):

``` r
tab(1:10, c(2, 5, 8))
#>  [1, 2)  [2, 5)  [5, 8) [8, 10] 
#>       1       3       3       3
```

### Chopping by width and number of elements

To chop into fixed-width intervals, starting at the minimum value, use
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md):

``` r
chopped <- chop_width(x, 2)
data.frame(x, chopped)
#>        x        chopped
#> 1  4.978 [3.086, 5.086)
#> 2  8.970 [7.086, 9.086)
#> 3  3.392 [3.086, 5.086)
#> 4  4.677 [3.086, 5.086)
#> 5  7.057 [5.086, 7.086)
#> 6  9.708 [9.086, 11.09]
#> 7  6.714 [5.086, 7.086)
#> 8  8.377 [7.086, 9.086)
#> 9  1.086 [1.086, 3.086)
#> 10 4.495 [3.086, 5.086)
```

To chop into a fixed number of intervals, each with the same width, use
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md):

``` r
chopped <- chop_evenly(x, intervals = 3)
data.frame(x, chopped)
#>        x        chopped
#> 1  4.978  [3.96, 6.834)
#> 2  8.970 [6.834, 9.708]
#> 3  3.392  [1.086, 3.96)
#> 4  4.677  [3.96, 6.834)
#> 5  7.057 [6.834, 9.708]
#> 6  9.708 [6.834, 9.708]
#> 7  6.714  [3.96, 6.834)
#> 8  8.377 [6.834, 9.708]
#> 9  1.086  [1.086, 3.96)
#> 10 4.495  [3.96, 6.834)
```

To chop into groups with a fixed number of elements, use
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md):

``` r
chopped <- chop_n(x, 4)
table(chopped)
#> chopped
#> [1.086, 4.978)  [4.978, 8.97)  [8.97, 9.708] 
#>              4              4              2
```

To chop into a fixed number of groups, each with the same number of
elements, use
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md):

``` r
chopped <- chop_equally(x, groups = 5)
table(chopped)
#> chopped
#> [1.086, 4.275) [4.275, 4.858) [4.858, 6.851) [6.851, 8.495) [8.495, 9.708] 
#>              2              2              2              2              2
```

To chop data up by quantiles, use
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md):

``` r
chopped <- chop_quantiles(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>        x     chopped
#> 1  4.978  [25%, 50%)
#> 2  8.970 [75%, 100%]
#> 3  3.392   [0%, 25%)
#> 4  4.677  [25%, 50%)
#> 5  7.057  [50%, 75%)
#> 6  9.708 [75%, 100%]
#> 7  6.714  [50%, 75%)
#> 8  8.377 [75%, 100%]
#> 9  1.086   [0%, 25%)
#> 10 4.495   [0%, 25%)
```

To chop data up by proportions of the data range, use
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md):

``` r
chopped <- chop_proportions(x, c(0.25, 0.5, 0.75))
data.frame(x, chopped)
#>        x        chopped
#> 1  4.978 [3.242, 5.397)
#> 2  8.970 [7.552, 9.708]
#> 3  3.392 [3.242, 5.397)
#> 4  4.677 [3.242, 5.397)
#> 5  7.057 [5.397, 7.552)
#> 6  9.708 [7.552, 9.708]
#> 7  6.714 [5.397, 7.552)
#> 8  8.377 [7.552, 9.708]
#> 9  1.086 [1.086, 3.242)
#> 10 4.495 [3.242, 5.397)
```

You can think of these six functions as logically arranged in a table.

| To chop into… | Sizing intervals by… |  |
|:---|:---|:---|
|   | number of elements: | interval width: |
| a specific number of equal intervals… | [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md) | [`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md) |
| intervals of one specific size… | [`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md) | [`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md) |
| intervals of different specific sizes… | [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md) | [`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md) |

Different ways to chop by size

### Even more ways to chop

To chop data by standard deviations around the mean, use
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md):

``` r
chopped <- chop_mean_sd(x)
data.frame(x, chopped)
#>        x        chopped
#> 1  4.978  [-1 sd, 0 sd)
#> 2  8.970   [1 sd, 2 sd)
#> 3  3.392  [-1 sd, 0 sd)
#> 4  4.677  [-1 sd, 0 sd)
#> 5  7.057   [0 sd, 1 sd)
#> 6  9.708   [1 sd, 2 sd)
#> 7  6.714   [0 sd, 1 sd)
#> 8  8.377   [0 sd, 1 sd)
#> 9  1.086 [-2 sd, -1 sd)
#> 10 4.495  [-1 sd, 0 sd)
```

To chop data into attractive intervals, use
[`chop_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md).
This selects intervals which are a multiple of 2, 5 or 10. It’s useful
for producing bar plots.

``` r
chopped <- chop_pretty(x)
data.frame(x, chopped)
#>        x chopped
#> 1  4.978  [4, 6)
#> 2  8.970 [8, 10]
#> 3  3.392  [2, 4)
#> 4  4.677  [4, 6)
#> 5  7.057  [6, 8)
#> 6  9.708 [8, 10]
#> 7  6.714  [6, 8)
#> 8  8.377 [8, 10]
#> 9  1.086  [0, 2)
#> 10 4.495  [4, 6)
```

### Isolating common values

In exploratory work, it’s sometimes useful to find common values and
treat them differently. You can use
[`dissect()`](https://hughjonesd.github.io/santoku/reference/dissect.md)
to do this:

``` r
x_spike <- rnorm(100)
x_spike[1:50] <- x_spike[1]

chopped <- dissect(x_spike, -3:3, prop = 0.1)
table(chopped)
#> chopped
#> [-3, -2) [-2, -1)  [-1, 0)   [0, 1) {0.6996}   [1, 2) 
#>        2        5       15       18       50       10
```

`prop = 0.2` will put any unique value of `x` into its own separate
category if it makes up at least 20% of the data.

Note that unlike all the other `chop_*` functions,
[`dissect()`](https://hughjonesd.github.io/santoku/reference/dissect.md)
doesn’t always categorize `x` into ordered, connected intervals. To
remind you of this, it is named differently. If you want to create
separate intervals on the left and right of common elements, use
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md):

``` r
chopped <- chop_spikes(x_spike, -3:3, prop = 0.1)
table(chopped)
#> chopped
#>    [-3, -2)    [-2, -1)     [-1, 0) [0, 0.6996)    {0.6996} (0.6996, 1) 
#>           2           5          15          13          50           5 
#>      [1, 2) 
#>          10
```

Compare this to the table before. There are two intervals on either side
of the common value, instead of one interval surrounding it.

### Quick tables

[`tab_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`tab_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
and friends act similarly to
[`tab()`](https://hughjonesd.github.io/santoku/reference/chop.md),
calling the related `chop_*` function and then
[`table()`](https://rdrr.io/r/base/table.html) on the result.

``` r
tab_n(x, 4)
#> [1.086, 4.978)  [4.978, 8.97)  [8.97, 9.708] 
#>              4              4              2
tab_width(x, 2)
#> [1.086, 3.086) [3.086, 5.086) [5.086, 7.086) [7.086, 9.086) [9.086, 11.09] 
#>              1              4              2              2              1
tab_evenly(x, 5)
#>  [1.086, 2.81)  [2.81, 4.535) [4.535, 6.259) [6.259, 7.983) [7.983, 9.708] 
#>              1              2              2              2              3
tab_mean_sd(x)
#> [-2 sd, -1 sd)  [-1 sd, 0 sd)   [0 sd, 1 sd)   [1 sd, 2 sd) 
#>              1              4              3              2
```

### Specifying labels

By default, santoku labels intervals using mathematical notation:

- `[0, 1]` means all numbers between 0 and 1 inclusive.
- `(0, 1)` means all numbers *strictly* between 0 and 1, not including
  the endpoints.
- `[0, 1)` means all numbers between 0 and 1, including 0 but not 1.
- `(0, 1]` means all numbers between 0 and 1, including 1 but not 0.
- `{0}` means just the number 0.

To override these labels, provide names to the `breaks` argument:

``` r
chopped <- chop(x, c(Lowest = 1, Low = 2, Higher = 5, Highest = 8))
data.frame(x, chopped)
#>        x chopped
#> 1  4.978     Low
#> 2  8.970 Highest
#> 3  3.392     Low
#> 4  4.677     Low
#> 5  7.057  Higher
#> 6  9.708 Highest
#> 7  6.714  Higher
#> 8  8.377 Highest
#> 9  1.086  Lowest
#> 10 4.495     Low
```

Or, you can specify factor labels with the `labels` argument:

``` r
chopped <- chop(x, c(2, 5, 8), labels = c("Lowest", "Low", "Higher", "Highest"))
data.frame(x, chopped)
#>        x chopped
#> 1  4.978     Low
#> 2  8.970 Highest
#> 3  3.392     Low
#> 4  4.677     Low
#> 5  7.057  Higher
#> 6  9.708 Highest
#> 7  6.714  Higher
#> 8  8.377 Highest
#> 9  1.086  Lowest
#> 10 4.495     Low
```

You need as many labels as there are intervals - one fewer than
`length(breaks)` if your data doesn’t extend beyond `breaks`, one more
than `length(breaks)` if it does.

To label intervals with a dash, use
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md):

``` r
chopped <- chop(x, c(2, 5, 8), labels = lbl_dash())
data.frame(x, chopped)
#>        x chopped
#> 1  4.978     2—5
#> 2  8.970 8—9.708
#> 3  3.392     2—5
#> 4  4.677     2—5
#> 5  7.057     5—8
#> 6  9.708 8—9.708
#> 7  6.714     5—8
#> 8  8.377 8—9.708
#> 9  1.086 1.086—2
#> 10 4.495     2—5
```

To label integer data, use
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md).
It uses more informative right endpoints:

``` r
chopped  <- chop(1:10, c(2, 5, 8), labels = lbl_discrete())
chopped2 <- chop(1:10, c(2, 5, 8), labels = lbl_dash())
data.frame(x = 1:10, lbl_discrete = chopped, lbl_dash = chopped2)
#>     x lbl_discrete lbl_dash
#> 1   1            1      1—2
#> 2   2          2—4      2—5
#> 3   3          2—4      2—5
#> 4   4          2—4      2—5
#> 5   5          5—7      5—8
#> 6   6          5—7      5—8
#> 7   7          5—7      5—8
#> 8   8         8—10     8—10
#> 9   9         8—10     8—10
#> 10 10         8—10     8—10
```

You can customize the first or last labels:

``` r
chopped <- chop(x, c(2, 5, 8), labels = lbl_dash(first = "< 2", last = "8+"))
data.frame(x, chopped)
#>        x chopped
#> 1  4.978     2—5
#> 2  8.970      8+
#> 3  3.392     2—5
#> 4  4.677     2—5
#> 5  7.057     5—8
#> 6  9.708      8+
#> 7  6.714     5—8
#> 8  8.377      8+
#> 9  1.086     < 2
#> 10 4.495     2—5
```

To label intervals in order use
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md):

``` r
chopped <- chop(x, c(2, 5, 8), labels = lbl_seq())
data.frame(x, chopped)
#>        x chopped
#> 1  4.978       b
#> 2  8.970       d
#> 3  3.392       b
#> 4  4.677       b
#> 5  7.057       c
#> 6  9.708       d
#> 7  6.714       c
#> 8  8.377       d
#> 9  1.086       a
#> 10 4.495       b
```

You can use numerals or even roman numerals:

``` r
chop(x, c(2, 5, 8), labels = lbl_seq("(1)"))
#>  [1] (2) (4) (2) (2) (3) (4) (3) (4) (1) (2)
#> Levels: (1) (2) (3) (4)
chop(x, c(2, 5, 8), labels = lbl_seq("i."))
#>  [1] ii.  iv.  ii.  ii.  iii. iv.  iii. iv.  i.   ii. 
#> Levels: i. ii. iii. iv.
```

Other labelling functions include:

- [`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md) -
  use left endpoints as labels
- [`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md) -
  use interval midpoints as labels
- [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md) -
  specify labels flexibly with the [glue](https://glue.tidyverse.org/)
  package

### Specifying breaks

By default,
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
extends `breaks` if necessary. If you don’t want that, set
`extend = FALSE`:

``` r
chopped <- chop(x, c(3, 5, 7), extend = FALSE)
data.frame(x, chopped)
#>        x chopped
#> 1  4.978  [3, 5)
#> 2  8.970    <NA>
#> 3  3.392  [3, 5)
#> 4  4.677  [3, 5)
#> 5  7.057    <NA>
#> 6  9.708    <NA>
#> 7  6.714  [5, 7]
#> 8  8.377    <NA>
#> 9  1.086    <NA>
#> 10 4.495  [3, 5)
```

Data outside the range of `breaks` will become `NA`.

By default, intervals are closed on the left, i.e. they include their
left endpoints. If you want right-closed intervals, set `left = FALSE`:

``` r
y <- 1:5
data.frame(
        y = y, 
        left_closed = chop(y, 1:5), 
        right_closed = chop(y, 1:5, left = FALSE)
      )
#>   y left_closed right_closed
#> 1 1      [1, 2)       [1, 2]
#> 2 2      [2, 3)       [1, 2]
#> 3 3      [3, 4)       (2, 3]
#> 4 4      [4, 5]       (3, 4]
#> 5 5      [4, 5]       (4, 5]
```

By default, the last interval is closed on both ends. If you want to
keep the last interval open at the end, set `close_end = FALSE`:

``` r
data.frame(
  y = y,
  end_closed = chop(y, 1:5),
  end_open   = chop(y, 1:5, close_end = FALSE)
)
#>   y end_closed end_open
#> 1 1     [1, 2)   [1, 2)
#> 2 2     [2, 3)   [2, 3)
#> 3 3     [3, 4)   [3, 4)
#> 4 4     [4, 5]   [4, 5)
#> 5 5     [4, 5]      {5}
```

## Chopping dates, times and other vectors

You can chop many kinds of vectors with santoku, including Date objects…

``` r
y2k <- as.Date("2000-01-01") + 0:10 * 7
data.frame(
  y2k = y2k,
  chopped = chop(y2k, as.Date(c("2000-02-01", "2000-03-01")))
)
#>           y2k                  chopped
#> 1  2000-01-01 [2000-01-01, 2000-02-01)
#> 2  2000-01-08 [2000-01-01, 2000-02-01)
#> 3  2000-01-15 [2000-01-01, 2000-02-01)
#> 4  2000-01-22 [2000-01-01, 2000-02-01)
#> 5  2000-01-29 [2000-01-01, 2000-02-01)
#> 6  2000-02-05 [2000-02-01, 2000-03-01)
#> 7  2000-02-12 [2000-02-01, 2000-03-01)
#> 8  2000-02-19 [2000-02-01, 2000-03-01)
#> 9  2000-02-26 [2000-02-01, 2000-03-01)
#> 10 2000-03-04 [2000-03-01, 2000-03-11]
#> 11 2000-03-11 [2000-03-01, 2000-03-11]
```

… and POSIXct (date-time) objects:

``` r
# hours of the 2020 Crew Dragon flight:
crew_dragon <- seq(as.POSIXct("2020-05-30 18:00", tz = "GMT"), 
                     length.out = 24, by = "hours")
liftoff <- as.POSIXct("2020-05-30 15:22", tz = "America/New_York")
dock    <- as.POSIXct("2020-05-31 10:16", tz = "America/New_York")

data.frame(
  crew_dragon = crew_dragon,
  chopped = chop(crew_dragon, c(liftoff, dock), 
                   labels = c("pre-flight", "flight", "docked"))
)
#> Warning in .check_tzones(e1, e2): 'tzone' attributes are inconsistent
#> Warning in .check_tzones(e1, e2): 'tzone' attributes are inconsistent
#>            crew_dragon    chopped
#> 1  2020-05-30 18:00:00 pre-flight
#> 2  2020-05-30 19:00:00 pre-flight
#> 3  2020-05-30 20:00:00     flight
#> 4  2020-05-30 21:00:00     flight
#> 5  2020-05-30 22:00:00     flight
#> 6  2020-05-30 23:00:00     flight
#> 7  2020-05-31 00:00:00     flight
#> 8  2020-05-31 01:00:00     flight
#> 9  2020-05-31 02:00:00     flight
#> 10 2020-05-31 03:00:00     flight
#> 11 2020-05-31 04:00:00     flight
#> 12 2020-05-31 05:00:00     flight
#> 13 2020-05-31 06:00:00     flight
#> 14 2020-05-31 07:00:00     flight
#> 15 2020-05-31 08:00:00     flight
#> 16 2020-05-31 09:00:00     flight
#> 17 2020-05-31 10:00:00     flight
#> 18 2020-05-31 11:00:00     flight
#> 19 2020-05-31 12:00:00     flight
#> 20 2020-05-31 13:00:00     flight
#> 21 2020-05-31 14:00:00     flight
#> 22 2020-05-31 15:00:00     docked
#> 23 2020-05-31 16:00:00     docked
#> 24 2020-05-31 17:00:00     docked
```

Note how santoku correctly handles the different timezones.

You can use
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
with objects from the `lubridate` package, to chop by irregular periods
such as months:

``` r
library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union
data.frame(
  y2k = y2k,
  chopped = chop_width(y2k, months(1))
)
#>           y2k                  chopped
#> 1  2000-01-01 [2000-01-01, 2000-02-01)
#> 2  2000-01-08 [2000-01-01, 2000-02-01)
#> 3  2000-01-15 [2000-01-01, 2000-02-01)
#> 4  2000-01-22 [2000-01-01, 2000-02-01)
#> 5  2000-01-29 [2000-01-01, 2000-02-01)
#> 6  2000-02-05 [2000-02-01, 2000-03-01)
#> 7  2000-02-12 [2000-02-01, 2000-03-01)
#> 8  2000-02-19 [2000-02-01, 2000-03-01)
#> 9  2000-02-26 [2000-02-01, 2000-03-01)
#> 10 2000-03-04 [2000-03-01, 2000-04-01)
#> 11 2000-03-11 [2000-03-01, 2000-04-01)
```

You can format labels using format strings from
[`strptime()`](https://rdrr.io/r/base/strptime.html).
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
is useful here:

``` r
data.frame(
  y2k = y2k,
  chopped = chop_width(y2k, months(1), labels = lbl_discrete(fmt = "%e %b"))
)
#>           y2k       chopped
#> 1  2000-01-01  1 Jan—31 Jan
#> 2  2000-01-08  1 Jan—31 Jan
#> 3  2000-01-15  1 Jan—31 Jan
#> 4  2000-01-22  1 Jan—31 Jan
#> 5  2000-01-29  1 Jan—31 Jan
#> 6  2000-02-05  1 Feb—29 Feb
#> 7  2000-02-12  1 Feb—29 Feb
#> 8  2000-02-19  1 Feb—29 Feb
#> 9  2000-02-26  1 Feb—29 Feb
#> 10 2000-03-04  1 Mar—31 Mar
#> 11 2000-03-11  1 Mar—31 Mar
```

You can also chop vectors with units, using the `units` package:

``` r
library(units)
#> udunits database from /Users/davidhugh-jones/Library/R/arm64/4.5/library/units/share/udunits/udunits2.xml

x <- set_units(1:10 * 10, cm)
br <- set_units(1:3, ft)
data.frame(
  x = x,
  chopped = chop(x, br)
)
#>           x                    chopped
#> 1   10 [cm] [ 10.00 [cm],  30.48 [cm])
#> 2   20 [cm] [ 10.00 [cm],  30.48 [cm])
#> 3   30 [cm] [ 10.00 [cm],  30.48 [cm])
#> 4   40 [cm] [ 30.48 [cm],  60.96 [cm])
#> 5   50 [cm] [ 30.48 [cm],  60.96 [cm])
#> 6   60 [cm] [ 30.48 [cm],  60.96 [cm])
#> 7   70 [cm] [ 60.96 [cm],  91.44 [cm])
#> 8   80 [cm] [ 60.96 [cm],  91.44 [cm])
#> 9   90 [cm] [ 60.96 [cm],  91.44 [cm])
#> 10 100 [cm] [ 91.44 [cm], 100.00 [cm]]
```

You should be able to chop anything that has a comparison operator. You
can even chop character data using lexical ordering. By default santoku
emits a warning in this case, to avoid accidentally misinterpreting
results:

``` r
chop(letters[1:10], c("d", "f"))
#> Warning in categorize_non_numeric(x, breaks, left): `x` or `breaks` is of type
#> character, using lexical sorting. To turn off this warning, run:
#> options(santoku.warn_character = FALSE)
#>  [1] [a, d) [a, d) [a, d) [d, f) [d, f) [f, j] [f, j] [f, j] [f, j] [f, j]
#> Levels: [a, d) [d, f) [f, j]
```

If you find a type of data that you can’t chop, please [file an
issue](https://github.com/hughjonesd/santoku/issues).
