# Chop using pretty breakpoints

`chop_pretty()` uses
[`base::pretty()`](https://rdrr.io/r/base/pretty.html) to calculate
breakpoints which are 1, 2 or 5 times a power of 10. These look nice in
graphs.

## Usage

``` r
chop_pretty(x, n = 5, ...)

brk_pretty(n = 5, ...)

tab_pretty(x, n = 5, ...)
```

## Arguments

- x:

  A vector.

- n:

  Positive integer passed to
  [`base::pretty()`](https://rdrr.io/r/base/pretty.html). How many
  intervals to chop into?

- ...:

  Passed to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) by
  `chop_pretty()` and `tab_pretty()`; passed to
  [`base::pretty()`](https://rdrr.io/r/base/pretty.html) by
  `brk_pretty()`.

## Value

`chop_*` functions return a
[`factor`](https://rdrr.io/r/base/factor.html) of the same length as
`x`.

`brk_*` functions return a
[`function`](https://rdrr.io/r/base/function.html) to create `breaks`.

`tab_*` functions return a contingency
[`table()`](https://rdrr.io/r/base/table.html).

## Details

[`base::pretty()`](https://rdrr.io/r/base/pretty.html) tries to return
`n+1` breakpoints, i.e. `n` intervals, but note that this is not
guaranteed. There are methods for Date and POSIXct objects.

For fine-grained control over
[`base::pretty()`](https://rdrr.io/r/base/pretty.html) parameters, use
`chop(x, brk_pretty(...))`.

## Examples

``` r
chop_pretty(1:10)
#>  [1] [0, 2)  [2, 4)  [2, 4)  [4, 6)  [4, 6)  [6, 8)  [6, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [0, 2) [2, 4) [4, 6) [6, 8) [8, 10]

chop(1:10, brk_pretty(n = 5, high.u.bias = 0))
#>  [1] [1, 2)  [2, 3)  [3, 4)  [4, 5)  [5, 6)  [6, 7)  [7, 8)  [8, 9)  [9, 10]
#> [10] [9, 10]
#> Levels: [1, 2) [2, 3) [3, 4) [4, 5) [5, 6) [6, 7) [7, 8) [8, 9) [9, 10]

tab_pretty(1:10)
#>  [0, 2)  [2, 4)  [4, 6)  [6, 8) [8, 10] 
#>       1       2       2       2       3 
```
