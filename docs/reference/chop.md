# Cut data into intervals

`chop()` cuts `x` into intervals. It returns a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`, representing which interval contains each element of `x`. `kiru()`
is an alias for `chop`. `tab()` calls `chop()` and returns a contingency
[`table`](https://rdrr.io/r/base/table.html) from the result.

## Usage

``` r
chop(
  x,
  breaks,
  labels = lbl_intervals(),
  extend = NULL,
  left = TRUE,
  close_end = TRUE,
  raw = NULL,
  drop = TRUE
)

kiru(
  x,
  breaks,
  labels = lbl_intervals(),
  extend = NULL,
  left = TRUE,
  close_end = TRUE,
  raw = NULL,
  drop = TRUE
)

tab(
  x,
  breaks,
  labels = lbl_intervals(),
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

- breaks:

  A numeric vector of cut-points, or a function to create cut-points
  from `x`.

- labels:

  A character vector of labels or a function to create labels.

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

`chop()` returns a [`factor`](https://rdrr.io/r/base/factor.html) of the
same length as `x`, representing the intervals containing the value of
`x`.

`tab()` returns a contingency
[`table`](https://rdrr.io/r/base/table.html).

## Details

`x` may be a numeric vector, or more generally, any vector which can be
compared with `<` and `==` (see
[Ops](https://rdrr.io/r/base/groupGeneric.html)). In particular
[Date](https://rdrr.io/r/base/Dates.html) and
[date-time](https://rdrr.io/r/base/DateTimeClasses.html) objects are
supported. Character vectors are supported with a warning.

### Breaks

`breaks` may be a vector or a function.

If it is a vector, `breaks` gives the interval endpoints. Repeating a
value creates a "singleton" interval, which contains only that value.
For example `breaks = c(1, 3, 3, 5)` creates 3 intervals: `[1, 3)`,
`{3}` and `(3, 5]`.

If `breaks` is a function, it is called with the `x`, `extend`, `left`
and `close_end` arguments, and should return an object of class
`breaks`. Use `brk_*` functions to create a variety of data-dependent
breaks.

Names of `breaks` may be used for labels. See "Labels" below.

### Options for breaks

By default, left-closed intervals are created. If `left` is `FALSE`,
right-closed intervals are created.

If `close_end` is `TRUE` the final break (or first break if `left` is
`FALSE`) will be closed at both ends. This guarantees that all values
`x` with `min(breaks) <= x <= max(breaks)` are included in the
intervals.

Before version 0.9.0, `close_end` was `FALSE` by default, and also
behaved differently with respect to extended breaks: see "Extending
intervals" below.

Using [mathematical set
notation](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md):

- If `left` is `TRUE` and `close_end` is `TRUE`, breaks will look like
  `[b1, b2), [b2, b3) ... [b_(n-1), b_n]`.

- If `left` is `FALSE` and `close_end` is `TRUE`, breaks will look like
  `[b1, b2], (b2, b3] ... (b_(n-1), b_n]`.

- If `left` is `TRUE` and `close_end` is `FALSE`, all breaks will look
  like `... [b1, b2) ...`.

- If `left` is `FALSE` and `close_end` is `FALSE`, all breaks will look
  like `... (b1, b2] ...`.

### Extending intervals

If `extend` is `TRUE`, intervals will be extended to
`[-Inf, min(breaks))` and `(max(breaks), Inf]`.

If `extend` is `NULL` (the default), intervals will be extended to
`[min(x), min(breaks))` and `(max(breaks), max(x)]`, only if necessary,
i.e. only if elements of `x` would be outside the unextended breaks.

If `extend` is `FALSE`, intervals are never extended.

Note that even when `extend = TRUE`, extended intervals will be dropped
from the factor levels if they contain no elements and `drop = TRUE`.

`close_end` is only relevant if intervals are not extended; extended
intervals are always closed on the outside. This is a change from
previous behaviour. Up to version 0.8.0, `close_end` was applied to the
last user-specified interval, before any extended intervals were
created.

Since 1.1.0, infinity is represented as \\\infty\\ in breaks on unicode
platforms. Set `options(santoku.infinity = "Inf")` to get the old
behaviour.

### Labels

`labels` may be a character vector. It should have the same length as
the (possibly extended) number of intervals. Alternatively, `labels` may
be a `lbl_*` function such as
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md).

If `breaks` is a named vector, then names of `breaks` will be used as
labels for the interval starting at the corresponding element. This
overrides the `labels` argument (but unnamed breaks will still use
`labels`). This feature is **\[experimental\]**.

If `labels` is `NULL`, then integer codes will be returned instead of a
factor.

If `raw` is `TRUE`, labels will show the actual interval endpoints,
usually numbers. If `raw` is `FALSE` then labels may show other objects,
such as quantiles for
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
and friends, proportions of the range for
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
or standard deviations for
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md).

If `raw` is `NULL` then `lbl_*` functions will use their default
(usually `FALSE`). Otherwise, the `raw` argument to `chop()` overrides
`raw` arguments passed into `lbl_*` functions directly.

### Miscellaneous

`NA` values in `x`, and values which are outside the extended endpoints,
return `NA`.

`kiru()` is a synonym for `chop()`. If you load `{tidyr}`, you can use
it to avoid confusion with
[`tidyr::chop()`](https://tidyr.tidyverse.org/reference/chop.html).

Note that `chop()`, like all of R, uses binary arithmetic. Thus, numbers
may not be exactly equal to what you think they should be. There is an
example below.

## See also

[`base::cut()`](https://rdrr.io/r/base/cut.html),
[`non-standard-types`](https://hughjonesd.github.io/santoku/reference/non-standard-types.md)
for chopping objects that aren't numbers.

Other chopping functions:
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
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

chop(1:7, c(2, 4, 6))
#> [1] [1, 2) [2, 4) [2, 4) [4, 6) [4, 6) [6, 7] [6, 7]
#> Levels: [1, 2) [2, 4) [4, 6) [6, 7]

chop(1:7, c(2, 4, 6), extend = FALSE)
#> [1] <NA>   [2, 4) [2, 4) [4, 6] [4, 6] [4, 6] <NA>  
#> Levels: [2, 4) [4, 6]

# Repeat a number for a singleton break:
chop(1:7, c(2, 4, 4, 6))
#> [1] [1, 2) [2, 4) [2, 4) {4}    (4, 6) [6, 7] [6, 7]
#> Levels: [1, 2) [2, 4) {4} (4, 6) [6, 7]

chop(1:7, c(2, 4, 6), left = FALSE)
#> [1] [1, 2] [1, 2] (2, 4] (2, 4] (4, 6] (4, 6] (6, 7]
#> Levels: [1, 2] (2, 4] (4, 6] (6, 7]

chop(1:7, c(2, 4, 6), close_end = FALSE)
#> [1] [1, 2) [2, 4) [2, 4) [4, 6) [4, 6) [6, 7] [6, 7]
#> Levels: [1, 2) [2, 4) [4, 6) [6, 7]

chop(1:7, brk_quantiles(c(0.25, 0.75)))
#> [1] [0%, 25%)   [0%, 25%)   [25%, 75%)  [25%, 75%)  [25%, 75%)  [75%, 100%]
#> [7] [75%, 100%]
#> Levels: [0%, 25%) [25%, 75%) [75%, 100%]

# A single break is fine if `extend` is not `FALSE`:
chop(1:7, 4)
#> [1] [1, 4) [1, 4) [1, 4) [4, 7] [4, 7] [4, 7] [4, 7]
#> Levels: [1, 4) [4, 7]

# Floating point inaccuracy:
chop(0.3/3, c(0, 0.1, 0.1, 1), labels = c("< 0.1", "0.1", "> 0.1"))
#> [1] < 0.1
#> Levels: < 0.1

# -- Labels --

chop(1:7, c(Lowest = 1, Low = 2, Mid = 4, High = 6))
#> [1] Lowest Low    Low    Mid    Mid    High   High  
#> Levels: Lowest Low Mid High

chop(1:7, c(2, 4, 6), labels = c("Lowest", "Low", "Mid", "High"))
#> [1] Lowest Low    Low    Mid    Mid    High   High  
#> Levels: Lowest Low Mid High

chop(1:7, c(2, 4, 6), labels = lbl_dash())
#> [1] 1—2 2—4 2—4 4—6 4—6 6—7 6—7
#> Levels: 1—2 2—4 4—6 6—7

# Mixing names and other labels:
chop(1:7, c("<2" = 1, 2, 4, ">=6" = 6), labels = lbl_dash())
#> [1] <2  2—4 2—4 4—6 4—6 >=6 >=6
#> Levels: <2 2—4 4—6 >=6

# -- Non-standard types --

chop(as.Date("2001-01-01") + 1:7, as.Date("2001-01-04"))
#> [1] [2001-01-02, 2001-01-04) [2001-01-02, 2001-01-04) [2001-01-04, 2001-01-08]
#> [4] [2001-01-04, 2001-01-08] [2001-01-04, 2001-01-08] [2001-01-04, 2001-01-08]
#> [7] [2001-01-04, 2001-01-08]
#> Levels: [2001-01-02, 2001-01-04) [2001-01-04, 2001-01-08]

suppressWarnings(chop(LETTERS[1:7], "D"))
#> [1] [A, D) [A, D) [A, D) [D, G] [D, G] [D, G] [D, G]
#> Levels: [A, D) [D, G]


tab(1:10, c(2, 5, 8))
#>  [1, 2)  [2, 5)  [5, 8) [8, 10] 
#>       1       3       3       3 
```
