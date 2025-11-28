# Create a `breaks` object manually

Create a `breaks` object manually

## Usage

``` r
brk_manual(breaks, left_vec)
```

## Arguments

- breaks:

  A vector, which must be sorted.

- left_vec:

  A logical vector, the same length as `breaks`. Specifies whether each
  break is left-closed or right-closed.

## Value

A function which returns an object of class `breaks`.

## Details

All breaks must be closed on exactly one side, like `..., x) [x, ...`
(left-closed) or `..., x) [x, ...` (right-closed).

For example, if `breaks = 1:3` and `left = c(TRUE, FALSE, TRUE)`, then
the resulting intervals are

    T        F       T
    [ 1,  2 ] ( 2, 3 )

Singleton breaks are created by repeating a number in `breaks`.
Singletons must be closed on both sides, so if there is a repeated
number at indices `i`, `i+1`, `left[i]` *must* be `TRUE` and `left[i+1]`
must be `FALSE`.

`brk_manual()` ignores `left` and `close_end` arguments passed in from
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
since `left_vec` sets these manually. `extend` and `drop` arguments are
respected as usual.

## Examples

``` r
lbrks <- brk_manual(1:3, rep(TRUE, 3))
chop(1:3, lbrks, extend = FALSE)
#> [1] [1, 2) [2, 3) <NA>  
#> Levels: [1, 2) [2, 3)

rbrks <- brk_manual(1:3, rep(FALSE, 3))
chop(1:3, rbrks, extend = FALSE)
#> [1] <NA>   (1, 2] (2, 3]
#> Levels: (1, 2] (2, 3]

brks_singleton <- brk_manual(
      c(1,    2,    2,     3),
      c(TRUE, TRUE, FALSE, TRUE))

chop(1:3, brks_singleton, extend = FALSE)
#> [1] [1, 2) {2}    <NA>  
#> Levels: [1, 2) {2}
```
