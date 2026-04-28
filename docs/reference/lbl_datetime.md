# Label dates and datetimes

**\[experimental\]**

`lbl_date()` and `lbl_datetime()` produce nice labels for dates and
datetimes. Where possible ranges are simplified, like like "13-14 Jul
2026" or "11:15-12:15 1 Dec 2025".

## Usage

``` r
lbl_date(
  fmt = "%e %b %Y",
  symbol = "-",
  unit = as.difftime(1, units = "days"),
  single = "{l}",
  first = NULL,
  last = NULL
)

lbl_datetime(
  fmt = "%H:%M:%S %b %e %Y",
  symbol = "-",
  unit = NULL,
  single = "{l}",
  first = NULL,
  last = NULL
)
```

## Arguments

- fmt:

  String, list or function. A format for break endpoints.

- symbol:

  String: separator to use for full ranges.

- unit:

  Optional interval unit for non-overlapping labels. If not `NULL`, .
  endpoints are adjusted in the style of
  [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md).

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
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
winter <- as.Date("2025-12-01") + 0:89
tab(winter, as.Date(c("2025-12-25", "2026-01-06")),
    labels = lbl_date())
#>             1-24 Dec 2025 25 Dec 2025 -  5 Jan 2026       6 Jan - 28 Feb 2026 
#>                        24                        12                        54 
new_year <- as.POSIXct("2025-12-31 23:00") + 0:120 * 60
round_midnight <- as.POSIXct(c("2025-12-31 23:59", "2026-01-01 00:05"))
tab(new_year, round_midnight,
    labels = lbl_datetime())
#>               23:00:00-23:59:00 Dec 31 2025 
#>                                          59 
#> 23:59:00 Dec 31 2025 - 00:05:00 Jan  1 2026 
#>                                           6 
#>               00:05:00-01:00:00 Jan  1 2026 
#>                                          56 
tab(new_year, round_midnight,
    labels = lbl_datetime(unit = as.difftime(1, units = "mins")))
#>               23:00:00-23:58:00 Dec 31 2025 
#>                                          59 
#> 23:59:00 Dec 31 2025 - 00:04:00 Jan  1 2026 
#>                                           6 
#>               00:05:00-01:00:00 Jan  1 2026 
#>                                          56 
```
