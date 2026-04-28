# Create a standard set of breaks

Create a standard set of breaks

## Usage

``` r
brk_default(breaks)
```

## Arguments

- breaks:

  A numeric vector.

## Value

A function which returns an object of class `breaks`.

## Examples

``` r

chop(1:10, c(2, 5, 8))
#>  [1] [1, 2)  [2, 5)  [2, 5)  [2, 5)  [5, 8)  [5, 8)  [5, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [1, 2) [2, 5) [5, 8) [8, 10]
chop(1:10, brk_default(c(2, 5, 8)))
#>  [1] [1, 2)  [2, 5)  [2, 5)  [2, 5)  [5, 8)  [5, 8)  [5, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [1, 2) [2, 5) [5, 8) [8, 10]
```
