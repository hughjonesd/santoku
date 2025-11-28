# Left- or right-closed breaks

**\[questioning\]**

## Usage

``` r
brk_left(breaks)

brk_right(breaks)
```

## Arguments

- breaks:

  A numeric vector.

## Value

A (function which returns an) object of class `breaks`.

## Details

These functions are in the "questioning" stage because they clash with
the `left` argument to
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) and
friends.

These functions override the `left` argument of
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

## Examples

``` r
chop(5:7, brk_left(5:7))
#> Warning: `brk_left()` was deprecated in santoku 0.4.0.
#> Please use the `left` argument to `chop()` instead.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_warnings()` to see where this warning was generated.
#> [1] [5, 6) [6, 7) {7}   
#> Levels: [5, 6) [6, 7) {7}

chop(5:7, brk_right(5:7))
#> Warning: `brk_right()` was deprecated in santoku 0.4.0.
#> Please use the `left` argument to `chop()` instead.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_warnings()` to see where this warning was generated.
#> Warning: `left` argument to `brk_right()` ignored
#> [1] {5}    (5, 6] (6, 7]
#> Levels: {5} (5, 6] (6, 7]

chop(5:7, brk_left(5:7))
#> [1] [5, 6) [6, 7) {7}   
#> Levels: [5, 6) [6, 7) {7}
```
