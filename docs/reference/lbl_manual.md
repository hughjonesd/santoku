# Defunct: label chopped intervals in a user-defined sequence

**\[defunct\]**

## Usage

``` r
lbl_manual(sequence, fmt = "%s")
```

## Arguments

- sequence:

  A character vector of labels.

- fmt:

  String, list or function. A format for break endpoints.

## Value

A function that creates a vector of labels.

## Details

`lbl_manual()` is defunct since santoku 1.0.0. It is little used and is
not closely related to the rest of the package. It also risks
mislabelling intervals, e.g. if intervals are extended. Use of
`lbl_manual()` will give an error.

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
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
if (FALSE) { # \dontrun{
chop(1:10, c(2, 5, 8), lbl_manual(c("w", "x", "y", "z")))
# ->
chop(1:10, c(2, 5, 8), labels = c("w", "x", "y", "z"))
} # }
```
