# Label discrete data

`lbl_discrete()` creates labels for discrete data, such as integers. For
example, breaks `c(1, 3, 4, 6, 7)` are labelled:
`"1-2", "3", "4-5", "6-7"`.

## Usage

``` r
lbl_discrete(
  symbol = em_dash(),
  unit = 1L,
  fmt = NULL,
  single = NULL,
  first = NULL,
  last = NULL
)
```

## Arguments

- symbol:

  String: symbol to use for the dash.

- unit:

  Minimum difference between distinct values of data. For integers, 1.

- fmt:

  String, list or function. A format for break endpoints.

- single:

  Glue string: label for singleton intervals. See
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  for details. If `NULL`, singleton intervals will be labelled the same
  way as other intervals.

- first:

  Glue string: override label for the first category. Write e.g.
  `first = "<{r}"` to create a label like `"<18"`. See
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  for details.

- last:

  String: override label for the last category. Write e.g.
  `last = ">{l}"` to create a label like `">65"`. See
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  for details.

## Value

A function that creates a vector of labels.

## Details

No check is done that the data are discrete-valued. If they are not,
then these labels may be misleading. Here, discrete-valued means that if
`x < y`, then `x <= y - unit`.

Be aware that Date objects may have non-integer values. See
[Date](https://rdrr.io/r/base/Dates.html).

## Formatting endpoints

If `fmt` is not `NULL` then it is used to format the endpoints.

- If `fmt` is a string, then numeric endpoints will be formatted by
  `sprintf(fmt, breaks)`; other endpoints, e.g.
  [Date](https://rdrr.io/r/base/Dates.html) objects, will be formatted
  by `format(breaks, fmt)`.

- If `fmt` is a list, then it will be used as arguments to
  [format](https://rdrr.io/r/base/format.html).

- If `fmt` is a function, it should take a vector of numbers (or other
  objects that can be used as breaks) and return a character vector. It
  may be helpful to use functions from the `{scales}` package, e.g.
  [`scales::label_comma()`](https://scales.r-lib.org/reference/label_number.html).

## See also

Other labelling functions:
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md),
[`lbl_date()`](https://hughjonesd.github.io/santoku/reference/lbl_datetime.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
tab(1:7, c(1, 3, 5), lbl_discrete())
#> 1—2 3—4 5—7 
#>   2   2   3 

tab(1:7, c(3, 5), lbl_discrete(first = "<= {r}"))
#> <= 2  3—4  5—7 
#>    2    2    3 

tab(1:7 * 1000, c(1, 3, 5) * 1000, lbl_discrete(unit = 1000))
#> 1000—2000 3000—4000 5000—7000 
#>         2         2         3 

# Misleading labels for non-integer data
chop(2.5, c(1, 3, 5), lbl_discrete())
#> [1] 1—2
#> Levels: 1—2
```
