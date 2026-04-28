# Chop using an existing function

`chop_fn()` is a convenience wrapper: `chop_fn(x, foo, ...)` is the same
as `chop(x, foo(x, ...))`.

## Usage

``` r
chop_fn(
  x,
  fn,
  ...,
  extend = NULL,
  left = TRUE,
  close_end = TRUE,
  raw = NULL,
  drop = TRUE
)

brk_fn(fn, ...)

tab_fn(
  x,
  fn,
  ...,
  extend = NULL,
  left = TRUE,
  close_end = TRUE,
  raw = NULL,
  drop = TRUE
)
```

## Arguments

- x:

  A vector.

- fn:

  A function which returns a numeric vector of breaks.

- ...:

  Further arguments to `fn`

- extend:

  Logical. If `TRUE`, always extend breaks to `+/-Inf`. If `NULL`,
  extend breaks to `min(x)` and/or `max(x)` only if necessary. If
  `FALSE`, never extend.

- left:

  Logical. Left-closed or right-closed breaks?

- close_end:

  Logical. Close last break at right? (If `left` is `FALSE`, close first
  break at left?)

- raw:

  Logical. Use raw values in labels?

- drop:

  Logical. Drop unused levels from the result?

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
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r

if (requireNamespace("scales")) {
  chop_fn(rlnorm(10), scales::breaks_log(5))
  # same as
  # x <- rlnorm(10)
  # chop(x, scales::breaks_log(5)(x))
}
#> Loading required namespace: scales
#>  [1] [0.1, 0.3)  [1, 3)      [0.03, 0.1) [0.3, 1)    [1, 3)      [3, 10]    
#>  [7] [0.1, 0.3)  [0.3, 1)    [0.3, 1)    [0.3, 1)   
#> Levels: [0.03, 0.1) [0.1, 0.3) [0.3, 1) [1, 3) [3, 10]
```
