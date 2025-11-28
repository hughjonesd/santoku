# Label chopped intervals with arbitrary formatting

**\[questioning\]**

## Usage

``` r
lbl_format(fmt, fmt1 = "%.3g", raw = FALSE)
```

## Arguments

- fmt:

  A format. Can be a string, passed into
  [`base::sprintf()`](https://rdrr.io/r/base/sprintf.html) or
  [`format()`](https://rdrr.io/r/base/format.html) methods; or a
  one-argument formatting function.

- fmt1:

  Format for breaks consisting of a single value.

- raw:

  Logical. Always use raw `breaks` in labels, rather than e.g. quantiles
  or standard deviations?

## Value

A vector of labels for `chop`, or a function that creates labels.

## Details

These labels let you format breaks arbitrarily, using either a string
(passed to [`sprintf()`](https://rdrr.io/r/base/sprintf.html)) or a
function.

If `fmt` is a function, it must accept two arguments, representing the
left and right endpoints of each interval.

If `breaks` are non-numeric, you can only use `"%s"` in a string `fmt`.
`breaks` will be converted to character in this case.

`lbl_format()` is in the "questioning" stage. As an alternative,
consider using
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md)
or
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md)
with the `fmt` argument.

## See also

Other labelling functions:
[`lbl_dash`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md)`()`,
[`lbl_discrete`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)`()`,
[`lbl_intervals`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md)`()`,
[`lbl_manual`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md)`()`,
[`lbl_seq`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)`()`

## Examples

``` r
tab(1:10, c(1,3, 3, 7),
      label = lbl_format("%.3g to %.3g"))
#>  1 to 3       3  3 to 7 7 to 10 
#>       2       1       3       4 
tab(1:10, c(1,3, 3, 7),
      label = lbl_format("%.3g to %.3g", "Exactly %.3g"))
#>    1 to 3 Exactly 3    3 to 7   7 to 10 
#>         2         1         3         4 

percent2 <- function (x, y) {
  sprintf("%.2f%% - %.2f%%", x*100, y*100)
}
tab(runif(100), c(0.25, 0.5, .75),
      labels = lbl_format(percent2))
#>  0.64% - 25.00% 25.00% - 50.00% 50.00% - 75.00% 75.00% - 98.41% 
#>              21              20              33              26 
```
