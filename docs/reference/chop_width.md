# Chop into fixed-width intervals

`chop_width()` chops `x` into intervals of fixed `width`.

## Usage

``` r
chop_width(x, width, start, ..., left = sign(width) > 0)

brk_width(width, start)

# Default S3 method
brk_width(width, start)

tab_width(x, width, start, ..., left = sign(width) > 0)
```

## Arguments

- x:

  A vector.

- width:

  Width of intervals.

- start:

  Starting point for intervals. By default the smallest finite `x`
  (largest if `width` is negative).

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

- left:

  Logical. Left-closed or right-closed breaks?

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table`](https://rdrr.io/r/base/table.html).

## Details

If `width` is negative, `chop_width()` sets `left = FALSE` and intervals
will go downwards from `start`.

## See also

[brk_width-for-datetime](https://hughjonesd.github.io/santoku/reference/brk_width-for-datetime.md)

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
[`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)

## Examples

``` r
chop_width(1:10, 2)
#>  [1] [1, 3)  [1, 3)  [3, 5)  [3, 5)  [5, 7)  [5, 7)  [7, 9)  [7, 9)  [9, 11]
#> [10] [9, 11]
#> Levels: [1, 3) [3, 5) [5, 7) [7, 9) [9, 11]

chop_width(1:10, 2, start = 0)
#>  [1] [0, 2)  [2, 4)  [2, 4)  [4, 6)  [4, 6)  [6, 8)  [6, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [0, 2) [2, 4) [4, 6) [6, 8) [8, 10]

chop_width(1:9, -2)
#> [1] [1, 3] [1, 3] [1, 3] (3, 5] (3, 5] (5, 7] (5, 7] (7, 9] (7, 9]
#> Levels: [1, 3] (3, 5] (5, 7] (7, 9]

chop(1:10, brk_width(2, 0))
#>  [1] [0, 2)  [2, 4)  [2, 4)  [4, 6)  [4, 6)  [6, 8)  [6, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [0, 2) [2, 4) [4, 6) [6, 8) [8, 10]

tab_width(1:10, 2, start = 0)
#>  [0, 2)  [2, 4)  [4, 6)  [6, 8) [8, 10] 
#>       1       2       2       2       3 
```
