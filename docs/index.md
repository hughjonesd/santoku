# santoku

santoku is a versatile cutting tool for R. It provides
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md), a
replacement for [`base::cut()`](https://rdrr.io/r/base/cut.html).

## Installation

Install from [r-universe](https://r-universe.dev):

``` r

install.packages("santoku", repos = c("https://hughjonesd.r-universe.dev", 
                                      "https://cloud.r-project.org"))
```

Or from CRAN:

``` r

install.packages("santoku")
```

Or get the development version from github:

``` r

# install.packages("remotes")
remotes::install_github("hughjonesd/santoku")
```

## Advantages

Here are some advantages of santoku:

- By default,
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  always covers the whole range of the data, so you won’t get unexpected
  `NA` values.

- [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) can
  handle single values as well as intervals. For example,
  `chop(x, breaks = c(1, 2, 2, 3))` will create a separate factor level
  for values exactly equal to 2.

- [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) can
  handle many kinds of data, including numbers, dates and times, and
  [units](https://r-quantities.github.io/units/).

- `chop_*` functions create intervals in many ways, using quantiles of
  the data, standard deviations, fixed-width intervals, equal-sized
  groups, or pretty intervals for use in graphs.

- It’s easy to label intervals: use names for your breaks vector, or use
  a `lbl_*` function to create interval notation like `[1, 2)`, dash
  notation like `1-2`, or arbitrary styles using
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html).

- `tab_*` functions quickly chop data, then tabulate it.

These advantages make santoku especially useful for exploratory
analysis, where you may not know the range of your data in advance.

## Examples

``` r

library(santoku)
```

`chop` returns a factor:

``` r

chop(1:5, c(2, 4))
#> [1] [1, 2) [2, 4) [2, 4) [4, 5] [4, 5]
#> Levels: [1, 2) [2, 4) [4, 5]
```

Include a number twice to match it exactly:

``` r

chop(1:5, c(2, 2, 4))
#> [1] [1, 2) {2}    (2, 4) [4, 5] [4, 5]
#> Levels: [1, 2) {2} (2, 4) [4, 5]
```

Use names in breaks for labels:

``` r

chop(1:5, c(Low = 1, Mid = 2, High = 4))
#> [1] Low  Mid  Mid  High High
#> Levels: Low Mid High
```

Or use `lbl_*` functions:

``` r

chop(1:5, c(2, 4), labels = lbl_dash())
#> [1] 1—2 2—4 2—4 4—5 4—5
#> Levels: 1—2 2—4 4—5
```

Chop into fixed-width intervals:

``` r

chop_width(runif(10), 0.1)
#>  [1] [0.368, 0.468)   [0.268, 0.368)   [0.768, 0.868]   [0.568, 0.668)  
#>  [5] [0.668, 0.768)   [0.768, 0.868]   [0.06801, 0.168) [0.668, 0.768)  
#>  [9] [0.06801, 0.168) [0.468, 0.568)  
#> 7 Levels: [0.06801, 0.168) [0.268, 0.368) [0.368, 0.468) ... [0.768, 0.868]
```

Or into fixed-size groups:

``` r

chop_n(1:10, 5)
#>  [1] [1, 6)  [1, 6)  [1, 6)  [1, 6)  [1, 6)  [6, 10] [6, 10] [6, 10] [6, 10]
#> [10] [6, 10]
#> Levels: [1, 6) [6, 10]
```

Chop dates by calendar month, then tabulate:

``` r

library(lubridate)
#> 
#> Attaching package: 'lubridate'
#> The following objects are masked from 'package:base':
#> 
#>     date, intersect, setdiff, union

dates <- as.Date("2021-12-31") + 1:90

tab_width(dates, months(1), labels = lbl_discrete(fmt = "%d %b"))
#> 01 Jan—31 Jan 01 Feb—28 Feb 01 Mar—31 Mar 
#>            31            28            31
```

For more information, see the
[vignette](https://hughjonesd.github.io/santoku/articles/santoku.html).
