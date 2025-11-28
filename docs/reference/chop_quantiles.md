# Chop by quantiles

`chop_quantiles()` chops data by quantiles. `chop_deciles()` is a
convenience function which chops into deciles.

## Usage

``` r
chop_quantiles(
  x,
  probs,
  ...,
  labels = if (raw) lbl_intervals() else lbl_intervals(single = NULL),
  left = is.numeric(x),
  raw = FALSE,
  weights = NULL,
  recalc_probs = FALSE
)

chop_deciles(x, ...)

brk_quantiles(probs, ..., weights = NULL, recalc_probs = FALSE)

tab_quantiles(x, probs, ..., left = is.numeric(x), raw = FALSE)

tab_deciles(x, ...)
```

## Arguments

- x:

  A vector.

- probs:

  A vector of probabilities for the quantiles. If `probs` has names,
  these will be used for labels.

- ...:

  For `chop_quantiles`, passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).
  For `brk_quantiles()`, passed to
  [`stats::quantile()`](https://rdrr.io/r/stats/quantile.html) or
  [`Hmisc::wtd.quantile()`](https://rdrr.io/pkg/Hmisc/man/wtd.stats.html).

- labels:

  A character vector of labels or a function to create labels.

- left:

  Logical. Left-closed or right-closed breaks?

- raw:

  Logical. Use raw values in labels?

- weights:

  `NULL` or numeric vector of same length as `x`. If not `NULL`,
  [`Hmisc::wtd.quantile()`](https://rdrr.io/pkg/Hmisc/man/wtd.stats.html)
  is used to calculate weighted quantiles.

- recalc_probs:

  Logical. Recalculate probabilities of quantiles using
  [`ecdf(x)`](https://rdrr.io/r/stats/ecdf.html)? See below.

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table()`](https://rdrr.io/r/base/table.html).

## Details

For non-numeric `x`, `left` is set to `FALSE` by default. This works
better for calculating "type 1" quantiles, since they round down. See
[`stats::quantile()`](https://rdrr.io/r/stats/quantile.html).

By default, `chop_quantiles()` shows the requested probabilities in the
labels. To show the numeric quantiles themselves, set `raw = TRUE`.

When `x` contains duplicates, consecutive quantiles may be the same
number. If so, interval labels may be misleading, and if
`recalc_probs = FALSE` a warning is emitted. Set `recalc_probs = TRUE`
to recalculate the probabilities of the quantiles using the [empirical
cumulative distribution function](https://rdrr.io/r/stats/ecdf.html) of
`x`. Doing so may give you different labels from what you expect, and
will remove any names from `probs`, but it never changes the actual
quantiles used for breaks. At present, `recalc_probs = TRUE` is
incompatible with non-null `weights`. See the example below.

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
chop_quantiles(1:10, 1:3/4)
#>  [1] [0%, 25%)   [0%, 25%)   [0%, 25%)   [25%, 50%)  [25%, 50%)  [50%, 75%) 
#>  [7] [50%, 75%)  [75%, 100%] [75%, 100%] [75%, 100%]
#> Levels: [0%, 25%) [25%, 50%) [50%, 75%) [75%, 100%]

chop_quantiles(1:10, c(Q1 = 0, Q2 = 0.25, Q3 = 0.5, Q4 = 0.75))
#>  [1] Q1 Q1 Q1 Q2 Q2 Q3 Q3 Q4 Q4 Q4
#> Levels: Q1 Q2 Q3 Q4

chop(1:10, brk_quantiles(1:3/4))
#>  [1] [0%, 25%)   [0%, 25%)   [0%, 25%)   [25%, 50%)  [25%, 50%)  [50%, 75%) 
#>  [7] [50%, 75%)  [75%, 100%] [75%, 100%] [75%, 100%]
#> Levels: [0%, 25%) [25%, 50%) [50%, 75%) [75%, 100%]

chop_deciles(1:10)
#>  [1] [0%, 10%)   [10%, 20%)  [20%, 30%)  [30%, 40%)  [40%, 50%)  [50%, 60%) 
#>  [7] [60%, 70%)  [70%, 80%)  [80%, 90%)  [90%, 100%]
#> 10 Levels: [0%, 10%) [10%, 20%) [20%, 30%) [30%, 40%) [40%, 50%) ... [90%, 100%]

# to label by the quantiles themselves:
chop_quantiles(1:10, 1:3/4, raw = TRUE)
#>  [1] [1, 3.25)   [1, 3.25)   [1, 3.25)   [3.25, 5.5) [3.25, 5.5) [5.5, 7.75)
#>  [7] [5.5, 7.75) [7.75, 10]  [7.75, 10]  [7.75, 10] 
#> Levels: [1, 3.25) [3.25, 5.5) [5.5, 7.75) [7.75, 10]

# duplicate quantiles:
x <- c(1, 1, 1, 2, 3)
quantile(x, 1:5/5)
#>  20%  40%  60%  80% 100% 
#>  1.0  1.0  1.4  2.2  3.0 
tab_quantiles(x, 1:5/5)
#> Warning: `x` has duplicate quantiles: break labels may be misleading
#>  [20%, 40%]  [60%, 80%) [80%, 100%] 
#>           3           1           1 
tab_quantiles(x, 1:5/5, recalc_probs = TRUE)
#>   [0%, 60%]  [60%, 80%) [80%, 100%] 
#>           3           1           1 
set.seed(42)
tab_quantiles(rnorm(100), probs = 1:3/4, raw = TRUE)
#> [-2.993, -0.6167) [-0.6167, 0.0898)  [0.0898, 0.6616)   [0.6616, 2.287] 
#>                25                25                25                25 
```
