# Label chopped intervals using set notation

These labels are the most exact, since they show you whether intervals
are "closed" or "open", i.e. whether they include their endpoints.

## Usage

``` r
lbl_intervals(
  fmt = NULL,
  single = "{{{l}}}",
  first = NULL,
  last = NULL,
  raw = FALSE
)
```

## Arguments

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

- raw:

  **\[deprecated\]**. Use the `raw` argument to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  instead.

## Value

A function that creates a vector of labels.

## Details

Mathematical set notation looks like this:

- `[a, b]`: all numbers `x` where `a <= x <= b`;

- `(a, b)`: all numbers where `a < x < b`;

- `[a, b)`: all numbers where `a <= x < b`;

- `(a, b]`: all numbers where `a < x <= b`;

- `{a}`: just the number `a` exactly.

## Formatting endpoints

If `fmt` is not `NULL` then it is used to format the endpoints.

- If `fmt` is a string, then numeric endpoints will be formatted by
  `sprintf(fmt, breaks)`; other endpoints, e.g.
  [Date](https://lubridate.tidyverse.org/reference/date_utils.html)
  objects, will be formatted by `format(breaks, fmt)`.

- If `fmt` is a list, then it will be used as arguments to
  [format](https://rdrr.io/r/base/format.html).

- If `fmt` is a function, it should take a vector of numbers (or other
  objects that can be used as breaks) and return a character vector. It
  may be helpful to use functions from the `{scales}` package, e.g.
  [`scales::label_comma()`](https://scales.r-lib.org/reference/label_number.html).

## See also

Other labelling functions:
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md),
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
tab(-10:10, c(-3, 0, 0, 3),
      labels = lbl_intervals())
#> [-10, -3)   [-3, 0)       {0}    (0, 3)   [3, 10] 
#>         7         3         1         2         8 

tab(-10:10, c(-3, 0, 0, 3),
      labels = lbl_intervals(fmt = list(nsmall = 1)))
#> [-10.0,  -3.0) [ -3.0,   0.0)        {  0.0} (  0.0,   3.0) [  3.0,  10.0] 
#>              7              3              1              2              8 

tab_evenly(runif(20), 10,
      labels = lbl_intervals(fmt = percent))
#>  [6.095%, 15.1%)  [15.1%, 24.11%) [24.11%, 33.11%) [33.11%, 42.12%) 
#>                1                2                4                2 
#> [42.12%, 51.12%) [51.12%, 60.13%) [60.13%, 69.13%) [78.14%, 87.14%) 
#>                2                4                1                2 
#> [87.14%, 96.15%] 
#>                2 
```
