# Chop by standard deviations

Intervals are measured in standard deviations on either side of the
mean.

## Usage

``` r
chop_mean_sd(x, sds = 1:3, ..., raw = FALSE, sd = deprecated())

brk_mean_sd(sds = 1:3, sd = deprecated())

tab_mean_sd(x, sds = 1:3, ..., raw = FALSE)
```

## Arguments

- x:

  A vector.

- sds:

  Positive numeric vector of standard deviations.

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- raw:

  Logical. Use raw values in labels?

- sd:

  **\[deprecated\]**

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table`](https://rdrr.io/r/base/table.html).

## Details

In version 0.7.0, these functions changed to specifying `sds` as a
vector. To chop 1, 2 and 3 standard deviations around the mean, write
`chop_mean_sd(x, sds = 1:3)` instead of `chop_mean_sd(x, sd = 3)`.

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
chop_mean_sd(1:10)
#>  [1] [-2 sd, -1 sd) [-2 sd, -1 sd) [-1 sd, 0 sd)  [-1 sd, 0 sd)  [-1 sd, 0 sd) 
#>  [6] [0 sd, 1 sd)   [0 sd, 1 sd)   [0 sd, 1 sd)   [1 sd, 2 sd)   [1 sd, 2 sd)  
#> Levels: [-2 sd, -1 sd) [-1 sd, 0 sd) [0 sd, 1 sd) [1 sd, 2 sd)

chop(1:10, brk_mean_sd())
#>  [1] [-2 sd, -1 sd) [-2 sd, -1 sd) [-1 sd, 0 sd)  [-1 sd, 0 sd)  [-1 sd, 0 sd) 
#>  [6] [0 sd, 1 sd)   [0 sd, 1 sd)   [0 sd, 1 sd)   [1 sd, 2 sd)   [1 sd, 2 sd)  
#> Levels: [-2 sd, -1 sd) [-1 sd, 0 sd) [0 sd, 1 sd) [1 sd, 2 sd)

tab_mean_sd(1:10)
#> [-2 sd, -1 sd)  [-1 sd, 0 sd)   [0 sd, 1 sd)   [1 sd, 2 sd) 
#>              2              3              3              2 
```
