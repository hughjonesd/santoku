# Chop data precisely (for programmers)

`fillet()` calls
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) with
`extend = FALSE` and `drop = FALSE`. This ensures that you get only the
`breaks` and `labels` you ask for. When programming, consider using
`fillet()` instead of
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

## Usage

``` r
fillet(
  x,
  breaks,
  labels = lbl_intervals(),
  left = TRUE,
  close_end = TRUE,
  raw = NULL
)
```

## Arguments

- x:

  A vector.

- breaks:

  A numeric vector of cut-points, or a function to create cut-points
  from `x`.

- labels:

  A character vector of labels or a function to create labels.

- left:

  Logical. Left-closed or right-closed breaks?

- close_end:

  Logical. Close last break at right? (If `left` is `FALSE`, close first
  break at left?)

- raw:

  Logical. Use raw values in labels?

## Value

`fillet()` returns a [`factor`](https://rdrr.io/r/base/factor.html) of
the same length as `x`, representing the intervals containing the value
of `x`.

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)

## Examples

``` r
fillet(1:10, c(2, 5, 8))
#>  [1] <NA>   [2, 5) [2, 5) [2, 5) [5, 8] [5, 8] [5, 8] [5, 8] <NA>   <NA>  
#> Levels: [2, 5) [5, 8]
```
