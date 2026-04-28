# Cut data into intervals, separating out common values

Sometimes it's useful to separate out common elements of `x`.
`dissect()` chops `x`, but puts common elements of `x` ("spikes") into
separate categories.

## Usage

``` r
dissect(
  x,
  breaks,
  ...,
  n = NULL,
  prop = NULL,
  spike_labels = "{{{l}}}",
  exclude_spikes = FALSE
)

tab_dissect(x, breaks, ..., n = NULL, prop = NULL)
```

## Arguments

- x, breaks, ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- n, prop:

  Scalar. Provide either `n`, a number of values, or `prop`, a
  proportion of `length(x)`. Values of `x` which occur at least this
  often will get their own singleton break.

- spike_labels:

  [Glue](https://glue.tidyverse.org/reference/glue.html) string for
  spike labels. Use `"{l}"` for the spike value.

- exclude_spikes:

  Logical. Exclude spikes before chopping `x`? This can affect the
  location of data-dependent breaks.

## Value

`dissect()` returns the result of
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md), but
with common values put into separate factor levels.

`tab_dissect()` returns a contingency
[table()](https://rdrr.io/r/base/table.html).

## Details

Unlike
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
`dissect()` doesn't break up intervals which contain a spike. As a
result, unlike `chop_*` functions, `dissect()` does not chop `x` into
disjoint intervals. See the examples.

If breaks are data-dependent, their labels may be misleading after
common elements have been removed. See the example below. To get round
this, set `exclude_spikes` to `TRUE`. Then breaks will be calculated
after removing spikes from the data.

Levels of the result are ordered by the minimum element in each level.
As a result, if `drop = FALSE`, empty levels will be placed last.

This function is **\[experimental\]**.

## See also

[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md)
for a different approach.

## Examples

``` r
x <- c(2, 3, 3, 3, 4)
dissect(x, c(2, 4), n = 3)
#> [1] [2, 4] {3}    {3}    {3}    [2, 4]
#> Levels: [2, 4] {3}
dissect(x, brk_width(2), prop = 0.5)
#> [1] [2, 4] {3}    {3}    {3}    [2, 4]
#> Levels: [2, 4] {3}

set.seed(42)
x <- runif(40, 0, 10)
x <- sample(x, 200, replace = TRUE)
# Compare:
table(dissect(x, brk_width(2, 0), prop = 0.05))
#> 
#>  [0, 2)  [2, 4)  [4, 6)  [6, 8) [8, 10] {9.057} 
#>      30      24      36      40      59      11 
# Versus:
tab_spikes(x, brk_width(2, 0), prop = 0.05)
#>      [0, 2)      [2, 4)      [4, 6)      [6, 8)  [8, 9.057)     {9.057} 
#>          30          24          36          40          22          11 
#> (9.057, 10] 
#>          37 

# Potentially confusing data-dependent breaks:
set.seed(42)
x <- rnorm(99)
x[1:9] <- x[1]
tab_quantiles(x, 1:2/3)
#>     [0%, 33.33%) [33.33%, 66.67%)   [66.67%, 100%] 
#>               33               33               33 
tab_dissect(x, brk_quantiles(1:2/3), n = 9)
#>     [0%, 33.33%) [33.33%, 66.67%)   [66.67%, 100%]          {1.371} 
#>               33               33               24                9 
# Calculate quantiles excluding spikes:
tab_dissect(x, brk_quantiles(1:2/3), n = 9, exclude_spikes = TRUE)
#>     [0%, 33.33%) [33.33%, 66.67%)   [66.67%, 100%]          {1.371} 
#>               30               30               30                9 
```
