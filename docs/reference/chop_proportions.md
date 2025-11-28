# Chop into proportions of the range of x

`chop_proportions()` chops `x` into `proportions` of its range,
excluding infinite values.

## Usage

``` r
chop_proportions(x, proportions, ..., raw = TRUE)

brk_proportions(proportions)

tab_proportions(x, proportions, ..., raw = TRUE)
```

## Arguments

- x:

  A vector.

- proportions:

  Numeric vector between 0 and 1: proportions of x's range. If
  `proportions` has names, these will be used for labels.

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- raw:

  Logical. Use raw values in labels?

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table()`](https://rdrr.io/r/base/table.html).

## Details

By default, labels show the raw numeric endpoints. To label intervals by
the proportions, use `raw = FALSE`.

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
chop_proportions(0:10, c(0.2, 0.8))
#>  [1] [0, 2)  [0, 2)  [2, 8)  [2, 8)  [2, 8)  [2, 8)  [2, 8)  [2, 8)  [8, 10]
#> [10] [8, 10] [8, 10]
#> Levels: [0, 2) [2, 8) [8, 10]
chop_proportions(0:10, c(Low = 0, Mid = 0.2, High = 0.8))
#>  [1] Low  Low  Mid  Mid  Mid  Mid  Mid  Mid  High High High
#> Levels: Low Mid High
```
