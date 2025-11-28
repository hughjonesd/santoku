# A versatile cutting tool for R: package overview and options

santoku is a tool for cutting data into intervals. It provides the
function
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
which is similar to base R's [`cut()`](https://rdrr.io/r/base/cut.html)
or [`Hmisc::cut2()`](https://rdrr.io/pkg/Hmisc/man/cut2.html).
`chop(x, breaks)` takes a vector `x` and returns a factor of the same
length, coding which interval each element of `x` falls into.

## Details

Here are some advantages of santoku:

- By default,
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  always covers the whole range of the data, so you won't get unexpected
  `NA` values.

- Unlike [`cut()`](https://rdrr.io/r/base/cut.html) or `cut2()`,
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) can
  handle single values as well as intervals. For example,
  `chop(x, breaks = c(1, 2, 2, 3))` will create a separate factor level
  for values exactly equal to 2.

- Flexible and easy labelling.

- Convenience functions for creating quantile intervals, evenly-spaced
  intervals or equal-sized groups.

- Convenience functions to quickly tabulate chopped data.

- Can chop numbers, dates, date-times and other objects.

These advantages make santoku especially useful for exploratory
analysis, where you may not know the range of your data in advance.

To get started, read the vignette:

    vignette("santoku")

For more details, start with the documentation for
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).

## Options

Santoku has two options:

- `options("santoku.infinity")` sets the symbol for infinity in breaks.
  The default is `NULL`, in which case the infinity symbol is used on
  platforms that support it, otherwise `"Inf"` is used.

- `options("santoku.warn_character")` warns if you try to chop a
  character vector. Set to `FALSE` to turn off this warning.

## See also

Useful links:

- <https://github.com/hughjonesd/santoku>

- <https://hughjonesd.github.io/santoku/>

- Report bugs at <https://github.com/hughjonesd/santoku/issues>

## Author

**Maintainer**: David Hugh-Jones <davidhughjones@gmail.com>

Other contributors:

- Daniel Possenriede <possenriede@gmail.com> \[contributor\]
