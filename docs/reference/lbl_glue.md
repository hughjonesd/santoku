# Label chopped intervals using the `glue` package

Use `"{l}"` and `"{r}"` to show the left and right endpoints of the
intervals.

## Usage

``` r
lbl_glue(
  label,
  fmt = NULL,
  single = NULL,
  first = NULL,
  last = NULL,
  raw = deprecated(),
  ...
)
```

## Arguments

- label:

  A glue string passed to
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html).

- fmt:

  String, list or function. A format for break endpoints.

- single:

  Glue string: label for singleton intervals. See `lbl_glue()` for
  details. If `NULL`, singleton intervals will be labelled the same way
  as other intervals.

- first:

  Glue string: override label for the first category. Write e.g.
  `first = "<{r}"` to create a label like `"<18"`. See `lbl_glue()` for
  details.

- last:

  String: override label for the last category. Write e.g.
  `last = ">{l}"` to create a label like `">65"`. See `lbl_glue()` for
  details.

- raw:

  **\[deprecated\]**. Throws an error. Use the `raw` argument to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  instead.

- ...:

  Further arguments passed to
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html).

## Value

A function that creates a vector of labels.

## Details

The following variables are available in the glue string:

- `l` is a character vector of left endpoints of intervals.

- `r` is a character vector of right endpoints of intervals.

- `l_closed` is a logical vector. Elements are `TRUE` when the left
  endpoint is closed.

- `r_closed` is a logical vector, `TRUE` when the right endpoint is
  closed.

Endpoints will be formatted by `fmt` before being passed to `glue()`.

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
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md),
[`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)

## Examples

``` r
tab(1:10, c(1, 3, 3, 7),
    labels = lbl_glue("{l} to {r}", single = "Exactly {l}"))
#>    1 to 3 Exactly 3    3 to 7   7 to 10 
#>         2         1         3         4 

tab(1:10 * 1000, c(1, 3, 5, 7) * 1000,
    labels = lbl_glue("{l}-{r}",
                      fmt = function(x) prettyNum(x, big.mark=',')))
#>  1,000-3,000  3,000-5,000  5,000-7,000 7,000-10,000 
#>            2            2            2            4 

# reproducing lbl_intervals():
interval_left <- "{ifelse(l_closed, '[', '(')}"
interval_right <- "{ifelse(r_closed, ']', ')')}"
glue_string <- paste0(interval_left, "{l}", ", ", "{r}", interval_right)
tab(1:10, c(1, 3, 3, 7), labels = lbl_glue(glue_string, single = "{{{l}}}"))
#>  [1, 3)     {3}  (3, 7) [7, 10] 
#>       2       1       3       4 
```
