
<!-- README.md is generated from README.Rmd. Please edit that file -->

# santoku

<!-- badges: start -->

<!-- badges: end -->

![santoku logo](man/figures/santoku-logo.png) santoku is a precision
cutting tool for R. It provides `chop()`, a replacement for
`base::cut()`.

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
#>            x    chopped
#> 1  0.4181325 [0.4, 0.5)
#> 2  0.4063344 [0.4, 0.5)
#> 3  0.6273600 [0.6, 0.7)
#> 4  0.8199363 [0.8, 0.9)
#> 5  0.2475049 [0.2, 0.3)
#> 6  0.6506643 [0.6, 0.7)
#> 7  0.2979784 [0.2, 0.3)
#> 8  0.1994534 [0.1, 0.2)
#> 9  0.6923164 [0.6, 0.7)
#> 10 0.2207948 [0.2, 0.3)
```
