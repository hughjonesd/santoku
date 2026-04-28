# What's new in santoku 0.9.0

Santoku 0.9.0 has a few changes.

## You can use break names for labels

On the command line, sometimes you’d like to quickly add labels to your
breaks. Now, you can do this simply by adding names to the `breaks`
vector:

``` r

library(santoku)

chop(1:5, c(1,3,5))
#> [1] [1, 3) [1, 3) [3, 5] [3, 5] [3, 5]
#> Levels: [1, 3) [3, 5]

chop(1:5, c(Low = 1, High = 3, 5))
#> [1] Low  Low  High High High
#> Levels: Low High
```

Break names override the `labels` argument, but you can still use this
for unnamed breaks:

``` r


ages <- sample(12:80, 20)
tab(ages, 
      c("Under 16" = 0, 16, 25, 35, 45, 55, "65 and over" = 65), 
      labels = lbl_discrete()
    )
#>    Under 16       16—24       25—34       35—44       45—54       55—64 
#>           1           1           2           3           3           4 
#> 65 and over 
#>           6
```

Names can also be used for labels in
[`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
and
[`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md):

``` r

x <- rnorm(10)
chopped <- chop_quantiles(x, 
                            c("Lower tail" = 0, 0.025, "Upper tail" = 0.975)
                          )
data.frame(x, chopped)
#>             x       chopped
#> 1  -1.3888607 [2.5%, 97.5%)
#> 2  -0.2787888 [2.5%, 97.5%)
#> 3  -0.1333213 [2.5%, 97.5%)
#> 4   0.6359504 [2.5%, 97.5%)
#> 5  -0.2842529 [2.5%, 97.5%)
#> 6  -2.6564554    Lower tail
#> 7  -2.4404669 [2.5%, 97.5%)
#> 8   1.3201133    Upper tail
#> 9  -0.3066386 [2.5%, 97.5%)
#> 10 -1.7813084 [2.5%, 97.5%)
```

This feature is experimental for now.

## `close_end` works differently

The `close_end` parameter is used to right-close the last break. This
used to be applied before breaks were extended to cover items beyond the
explicitly given breaks. We think this was confusing for users. So now,
`close_end` is applied only after the breaks have been extended -
i.e. to the very last break.

In 0.8.0:

``` r

chop(1:4, 2:3, close_end = TRUE)
#> [1] [1, 2) [2, 3] [2, 3] (3, 4]
#> Levels: [1, 2) [2, 3] (3, 4]
```

Notice how the central break `[2, 3]` is right-closed. (The extended
break `[3, 4]` is right-closed too, because extended breaks are always
closed at the “outer” end.)

In 0.9.0:

``` r

chop(1:4, 2:3, close_end = TRUE)
#> [1] [1, 2) [2, 3) [3, 4] [3, 4]
#> Levels: [1, 2) [2, 3) [3, 4]
```

Now, `close_end` is applied to the final, extended break `[3, 4]`, not
to the explicit break `[2, 3)`.

## `close_end` is `TRUE` by default

We think that for exploratory work, users typically want to include all
the data between the lowest and highest break, inclusive. So,
`close_end` is now `TRUE` by default.

In 0.8.0:

``` r

chop(1:3, 2:3)
#> [1] [1, 2) [2, 3) {3}   
#> Levels: [1, 2) [2, 3) {3}
```

In 0.9.0:

``` r

chop(1:3, 2:3)
#> [1] [1, 2) [2, 3] [2, 3]
#> Levels: [1, 2) [2, 3]
```

## New `raw` parameter for `chop()`

`lbl_*` functions have a `raw` parameter to use the raw interval
endpoints in labels, rather than e.g. percentiles or standard
deviations. We’ve moved this into the main
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
function. This makes it easier to use:

``` r


chop_mean_sd(x)
#>  [1] [-1 sd, 0 sd)  [0 sd, 1 sd)   [0 sd, 1 sd)   [1 sd, 2 sd)   [0 sd, 1 sd)  
#>  [6] [-2 sd, -1 sd) [-2 sd, -1 sd) [1 sd, 2 sd)   [0 sd, 1 sd)   [-1 sd, 0 sd) 
#> Levels: [-2 sd, -1 sd) [-1 sd, 0 sd) [0 sd, 1 sd) [1 sd, 2 sd)

chop_mean_sd(x, raw = TRUE)
#>  [1] [-2.03, -0.7314)  [-0.7314, 0.5674) [-0.7314, 0.5674) [0.5674, 1.866)  
#>  [5] [-0.7314, 0.5674) [-3.329, -2.03)   [-3.329, -2.03)   [0.5674, 1.866)  
#>  [9] [-0.7314, 0.5674) [-2.03, -0.7314) 
#> 4 Levels: [-3.329, -2.03) [-2.03, -0.7314) ... [0.5674, 1.866)
```

The `raw` parameter to `lbl_*` functions is deprecated.

## Other changes

The NEWS file lists other changes, including a new
[`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md)
function which creates breaks using any arbitrary function.

## Feedback

We expect this to be the last release before 1.0, when we’ll stabilize
the interface and move santoku from “experimental” to “stable”. So, if
you have problems or suggestions regarding any of these changes, please
[file an issue](https://github.com/hughjonesd/santoku/issues).
