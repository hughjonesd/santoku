# Chop into equal-width intervals

`chop_evenly()` chops `x` into `intervals` intervals of equal width.

## Usage

``` r
chop_evenly(x, intervals, ...)

brk_evenly(intervals)

tab_evenly(x, intervals, ...)
```

## Arguments

- x:

  A vector.

- intervals:

  Integer: number of intervals to create.

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table`](https://rdrr.io/r/base/table.html).

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
chop_evenly(0:10, 5)
#>  [1] [0, 2)  [0, 2)  [2, 4)  [2, 4)  [4, 6)  [4, 6)  [6, 8)  [6, 8)  [8, 10]
#> [10] [8, 10] [8, 10]
#> Levels: [0, 2) [2, 4) [4, 6) [6, 8) [8, 10]
```
