# Equal-width intervals for dates or datetimes

[`brk_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
can be used with time interval classes from base R or the `lubridate`
package.

## Usage

``` r
# S3 method for class 'Duration'
brk_width(width, start)
```

## Arguments

- width:

  A scalar [difftime](https://rdrr.io/r/base/difftime.html),
  [Period](https://lubridate.tidyverse.org/reference/Period-class.html)
  or
  [Duration](https://lubridate.tidyverse.org/reference/Duration-class.html)
  object.

- start:

  A scalar of class [Date](https://rdrr.io/r/base/Dates.html) or
  [POSIXct](https://rdrr.io/r/base/DateTimeClasses.html). Can be
  omitted.

## Details

If `width` is a Period,
[`lubridate::add_with_rollback()`](https://lubridate.tidyverse.org/reference/mplus.html)
is used to calculate the widths. This can be useful for e.g. calendar
months.

## Examples

``` r

if (requireNamespace("lubridate")) {
  year2001 <- as.Date("2001-01-01") + 0:364
  tab_width(year2001, months(1),
        labels = lbl_discrete(" to ", fmt = "%e %b %y"))
}
#>  1 Jan 01 to 31 Jan 01  1 Feb 01 to 28 Feb 01  1 Mar 01 to 31 Mar 01 
#>                     31                     28                     31 
#>  1 Apr 01 to 30 Apr 01  1 May 01 to 31 May 01  1 Jun 01 to 30 Jun 01 
#>                     30                     31                     30 
#>  1 Jul 01 to 31 Jul 01  1 Aug 01 to 31 Aug 01  1 Sep 01 to 30 Sep 01 
#>                     31                     31                     30 
#>  1 Oct 01 to 31 Oct 01  1 Nov 01 to 30 Nov 01  1 Dec 01 to 31 Dec 01 
#>                     31                     30                     31 
```
