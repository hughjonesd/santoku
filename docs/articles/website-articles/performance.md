# Performance

## Speed

The core of santoku is written in C++. It is reasonably fast:

``` r

packageVersion("santoku")
#> [1] '1.1.0'
set.seed(27101975)

mb <- bench::mark(min_iterations = 100, check = FALSE,
        santoku::chop(rnorm(1e5), -2:2),
        base::cut(rnorm(1e5), -2:2),
        Hmisc::cut2(rnorm(1e5), -2:2)
      )
mb
#> # A tibble: 3 × 6
#>   expression                            min  median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                        <bch:t> <bch:t>     <dbl> <bch:byt>    <dbl>
#> 1 santoku::chop(rnorm(1e+05), -2:2)  7.04ms  7.46ms     134.    10.21MB     54.6
#> 2 base::cut(rnorm(1e+05), -2:2)      3.14ms  3.29ms     302.     2.35MB     24.8
#> 3 Hmisc::cut2(rnorm(1e+05), -2:2)   10.96ms 11.51ms      86.7   20.65MB    217.
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
#> 1 santoku::chop(rnorm(10000), many… 21.29ms 21.72ms      45.8    5.14MB     8.09
#> 2 base::cut(rnorm(10000), many_bre…  2.43ms  2.52ms     394.     1.39MB    20.0 
#> 3 Hmisc::cut2(rnorm(10000), many_b…  7.32ms  7.57ms     132.     5.86MB    30.9
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
#>  1 chop(x, -2:2)                     4.58ms  4.93ms     202.     8.63MB    109. 
#>  2 chop_equally(x, groups = 20)     11.18ms  11.6ms      85.7   12.18MB     70.2
#>  3 chop_n(x, n = 20000)              8.64ms  9.05ms     110.     23.5MB    414. 
#>  4 chop_quantiles(x, c(0.05, 0.25,…   6.5ms  7.11ms     141.    12.08MB    115. 
#>  5 chop_evenly(x, intervals = 20)    5.58ms  5.95ms     168.    12.48MB    155. 
#>  6 chop_width(x, width = 0.25)        6.3ms  6.63ms     150.    12.54MB    133. 
#>  7 chop_proportions(x, proportions…  5.28ms  5.87ms     172.    12.48MB    152. 
#>  8 chop_mean_sd(x, sds = 1:4)        5.24ms  5.65ms     177.    11.36MB    128. 
#>  9 chop_fn(x, scales::breaks_exten…  4.88ms   5.2ms     192.    11.47MB    139. 
#> 10 chop_pretty(x, n = 10)            4.58ms  4.82ms     207.    10.57MB    144. 
#> 11 chop_spikes(x, -2:2, prop = 0.0…  8.42ms  8.78ms     114.    14.62MB    119. 
#> 12 dissect(x, -2:2, prop = 0.01)    11.87ms 12.37ms      78.7   22.27MB    297.
```

``` r
autoplot(mb_various, type = "violin")
```

![](performance_files/figure-html/unnamed-chunk-3-1.png)
