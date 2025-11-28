# Chop equal-sized groups

`chop_equally()` chops `x` into groups with an equal number of elements.

## Usage

``` r
chop_equally(
  x,
  groups,
  ...,
  labels = lbl_intervals(),
  left = is.numeric(x),
  raw = TRUE
)

brk_equally(groups)

tab_equally(x, groups, ..., left = is.numeric(x), raw = TRUE)
```

## Arguments

- x:

  A vector.

- groups:

  Number of groups.

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- labels:

  A character vector of labels or a function to create labels.

- left:

  Logical. Left-closed or right-closed breaks?

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

`chop_equally()` uses
[`brk_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
under the hood. If `x` has duplicate elements, you may get fewer
`groups` than requested. If so, a warning will be emitted. See the
examples.

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
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
chop_equally(1:10, 5)
#>  [1] [1, 2.8)   [1, 2.8)   [2.8, 4.6) [2.8, 4.6) [4.6, 6.4) [4.6, 6.4)
#>  [7] [6.4, 8.2) [6.4, 8.2) [8.2, 10]  [8.2, 10] 
#> Levels: [1, 2.8) [2.8, 4.6) [4.6, 6.4) [6.4, 8.2) [8.2, 10]

# You can't always guarantee equal-sized groups:
dupes <- c(1, 1, 1, 2, 3, 4, 4, 4)
quantile(dupes, 0:4/4)
#>   0%  25%  50%  75% 100% 
#>  1.0  1.0  2.5  4.0  4.0 
chop_equally(dupes, 4)
#> Warning: `x` has duplicate quantiles: break labels may be misleading
#> [1] {1}      {1}      {1}      (1, 2.5) [2.5, 4) {4}      {4}      {4}     
#> Levels: {1} (1, 2.5) [2.5, 4) {4}
# Or as many groups as you ask for:
chop_equally(c(1, 1, 2, 2), 3)
#> Warning: `x` has duplicate quantiles: break labels may be misleading
#> [1] {1} {1} {2} {2}
#> Levels: {1} {2}
```
