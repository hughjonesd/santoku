
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku

<!-- badges: start -->

<!-- badges: end -->

Santoku is a precision cutting tool for R. It provides `chop()`, a
replacement for `base::cut()`.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hughjonesd/santoku")
```

## Example

``` r
library(santoku)
x <- runif(10)
chopped <- chop(x, 0:10/10)
data.frame(x, chopped)
#>             x    chopped
#> 1  0.53074696 [0.5, 0.6)
#> 2  0.20106703 [0.2, 0.3)
#> 3  0.07352994   [0, 0.1)
#> 4  0.07699423   [0, 0.1)
#> 5  0.12395232 [0.1, 0.2)
#> 6  0.05612991   [0, 0.1)
#> 7  0.72590780 [0.7, 0.8)
#> 8  0.74297094 [0.7, 0.8)
#> 9  0.25771189 [0.2, 0.3)
#> 10 0.72528738 [0.7, 0.8)
```
