# Chop into fixed-sized groups

`chop_n()` creates intervals containing a fixed number of elements.

## Usage

``` r
chop_n(x, n, ..., tail = "split")

brk_n(n, tail = "split")

tab_n(x, n, ..., tail = "split")
```

## Arguments

- x:

  A vector.

- n:

  Integer. Number of elements in each interval.

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- tail:

  String. What to do if the final interval has fewer than `n` elements?
  `"split"` to keep it separate. `"merge"` to merge it with the
  neighbouring interval.

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table()`](https://rdrr.io/r/base/table.html).

## Details

The algorithm guarantees that intervals contain no more than `n`
elements, so long as there are no duplicates in `x` and
`tail = "split"`. It also guarantees that intervals contain no fewer
than `n` elements, except possibly the last interval (or first interval
if `left` is `FALSE`).

To ensure that all intervals contain at least `n` elements (so long as
there are at least `n` elements in `x`!) set `tail = "merge"`.

If `tail = "split"` and there are intervals containing duplicates with
more than `n` elements, a warning is given.

## See also

Other chopping functions:
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
[`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
[`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
[`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md),
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
[`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md),
[`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md),
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
chop_n(1:10, 5)
#>  [1] [1, 6)  [1, 6)  [1, 6)  [1, 6)  [1, 6)  [6, 10] [6, 10] [6, 10] [6, 10]
#> [10] [6, 10]
#> Levels: [1, 6) [6, 10]

chop_n(1:5, 2)
#> [1] [1, 3) [1, 3) [3, 5) [3, 5) {5}   
#> Levels: [1, 3) [3, 5) {5}
chop_n(1:5, 2, tail = "merge")
#> [1] [1, 3) [1, 3) [3, 5] [3, 5] [3, 5]
#> Levels: [1, 3) [3, 5]

# too many duplicates
x <- rep(1:2, each = 3)
chop_n(x, 2)
#> Warning: Some intervals contain more than 2 elements
#> [1] [1, 2) [1, 2) [1, 2) {2}    {2}    {2}   
#> Levels: [1, 2) {2}

tab_n(1:10, 5)
#>  [1, 6) [6, 10] 
#>       5       5 

# fewer elements in one group
tab_n(1:10, 4)
#>  [1, 5)  [5, 9) [9, 10] 
#>       4       4       2 
```
