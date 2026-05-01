# Performance

## Speed

The core of santoku is written in C++. It is reasonably fast:

``` r


packageVersion("santoku")
#> [1] '1.2.1'
set.seed(27101975)

mb <- bench::mark(min_iterations = 100, check = FALSE,
        santoku::chop(rnorm(1e5), -2:2),
        base::cut(rnorm(1e5), -2:2),
        Hmisc::cut2(rnorm(1e5), -2:2)
      )
mb
#> # A tibble: 3 × 6
#>   expression                             min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                        <bch:tm> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 santoku::chop(rnorm(1e+05), -2:2)    6.3ms 6.53ms      151.   10.21MB     64.5
#> 2 base::cut(rnorm(1e+05), -2:2)       2.73ms 2.77ms      358.    2.35MB     31.5
#> 3 Hmisc::cut2(rnorm(1e+05), -2:2)     9.67ms 9.85ms      101.    19.5MB    224.
```

``` r

autoplot(mb, type = "violin")
```

![](performance_files/figure-html/unnamed-chunk-1-1.png)

## Many breaks

``` r


many_breaks <- seq(-2, 2, 0.001)

mb_breaks <- bench::mark(min_iterations = 100, check = FALSE,
        santoku::chop(rnorm(1e4), many_breaks),
        base::cut(rnorm(1e4), many_breaks),
        Hmisc::cut2(rnorm(1e4), many_breaks)
      )

mb_breaks
#> # A tibble: 3 × 6
#>   expression                            min  median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                        <bch:t> <bch:t>     <dbl> <bch:byt>    <dbl>
#> 1 santoku::chop(rnorm(10000), many… 20.88ms 21.22ms      46.9    5.14MB     8.93
#> 2 base::cut(rnorm(10000), many_bre…  2.36ms  2.45ms     407.     1.39MB    17.7 
#> 3 Hmisc::cut2(rnorm(10000), many_b…  7.03ms  7.21ms     138.      5.7MB    32.5
```

``` r

autoplot(mb_breaks, type = "violin")
```

![](performance_files/figure-html/unnamed-chunk-2-1.png)

## Various chops

``` r


x <- c(rnorm(9e4), sample(-2:2, 1e4, replace = TRUE))

mb_various <- bench::mark(min_iterations = 100, check = FALSE,
        chop(x, -2:2),
        chop_equally(x, groups = 20),
        chop_n(x, n = 2e4),
        chop_quantiles(x, c(0.05, 0.25, 0.5, 0.75, 0.95)),
        chop_evenly(x, intervals = 20),
        chop_width(x, width = 0.25),
        chop_proportions(x, proportions = c(0.05, 0.25, 0.5, 0.75, 0.95)),
        chop_mean_sd(x, sds = 1:4),
        chop_fn(x, scales::breaks_extended(10)),
        chop_pretty(x, n = 10),
        chop_spikes(x, -2:2, prop = 0.01),
        dissect(x, -2:2, prop = 0.01)
      )
      
mb_various
#> # A tibble: 12 × 6
#>    expression                           min  median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>                       <bch:t> <bch:t>     <dbl> <bch:byt>    <dbl>
#>  1 chop(x, -2:2)                     4.59ms  4.73ms     209.     8.63MB     93.9
#>  2 chop_equally(x, groups = 20)     10.84ms 11.02ms      90.2   12.18MB     76.8
#>  3 chop_n(x, n = 20000)              7.87ms  8.03ms     124.     23.5MB    541. 
#>  4 chop_quantiles(x, c(0.05, 0.25,…   6.8ms  6.97ms     143.    12.08MB    122. 
#>  5 chop_evenly(x, intervals = 20)    5.25ms  5.36ms     185.    12.48MB    158. 
#>  6 chop_width(x, width = 0.25)        5.9ms  6.07ms     164.    12.54MB    134. 
#>  7 chop_proportions(x, proportions…  4.71ms  4.84ms     206.    12.48MB    176. 
#>  8 chop_mean_sd(x, sds = 1:4)           5ms  5.14ms     194.    11.36MB    147. 
#>  9 chop_fn(x, scales::breaks_exten…  4.86ms  5.14ms     191.    11.47MB    144. 
#> 10 chop_pretty(x, n = 10)            4.53ms  4.68ms     213.    10.58MB    148. 
#> 11 chop_spikes(x, -2:2, prop = 0.0…  8.03ms  8.17ms     122.    14.62MB    132. 
#> 12 dissect(x, -2:2, prop = 0.01)    11.71ms 11.87ms      84.0   22.27MB    269.
```

``` r

autoplot(mb_various, type = "violin")
```

![](performance_files/figure-html/unnamed-chunk-3-1.png)
