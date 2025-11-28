# Chop common values into singleton intervals

`chop_spikes()` lets you chop common values of `x` into their own
singleton intervals. This can help make unusual values visible.

## Usage

``` r
chop_spikes(x, breaks, ..., n = NULL, prop = NULL)

brk_spikes(breaks, n = NULL, prop = NULL)

tab_spikes(x, breaks, ..., n = NULL, prop = NULL)
```

## Arguments

- x:

  A vector.

- breaks:

  A numeric vector of cut-points or a call to a `brk_*` function. The
  resulting
  [`breaks`](https://hughjonesd.github.io/santoku/reference/breaks-class.md)
  object will be modified to add singleton breaks.

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- n, prop:

  Scalar. Provide either `n`, a number of values, or `prop`, a
  proportion of `length(x)`. Values of `x` which occur at least this
  often will get their own singleton break.

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table()`](https://rdrr.io/r/base/table.html).

## Details

This function is **\[experimental\]**.

## See also

[`dissect()`](https://hughjonesd.github.io/santoku/reference/dissect.md)
for a different approach.

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
x <- c(1:4, rep(5, 5), 6:10)
chop_spikes(x, c(2, 7), n = 5)
#>  [1] [1, 2)  [2, 5)  [2, 5)  [2, 5)  {5}     {5}     {5}     {5}     {5}    
#> [10] (5, 7)  [7, 10] [7, 10] [7, 10] [7, 10]
#> Levels: [1, 2) [2, 5) {5} (5, 7) [7, 10]
chop_spikes(x, c(2, 7), prop = 0.25)
#>  [1] [1, 2)  [2, 5)  [2, 5)  [2, 5)  {5}     {5}     {5}     {5}     {5}    
#> [10] (5, 7)  [7, 10] [7, 10] [7, 10] [7, 10]
#> Levels: [1, 2) [2, 5) {5} (5, 7) [7, 10]
chop_spikes(x, brk_width(5), n = 5)
#>  [1] [1, 5)  [1, 5)  [1, 5)  [1, 5)  {5}     {5}     {5}     {5}     {5}    
#> [10] [6, 11] [6, 11] [6, 11] [6, 11] [6, 11]
#> Levels: [1, 5) {5} [6, 11]

set.seed(42)
x <- runif(40, 0, 10)
x <- sample(x, 200, replace = TRUE)
tab_spikes(x, brk_width(2, 0), prop = 0.05)
#>      [0, 2)      [2, 4)      [4, 6)      [6, 8)  [8, 9.057)     {9.057} 
#>          30          24          36          40          22          11 
#> (9.057, 10] 
#>          37 
```
