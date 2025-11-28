# Define singleton intervals explicitly

`exactly()` duplicates its input. It lets you define singleton intervals
like this: `chop(x, c(1, exactly(2), 3))`. This is the same as
`chop(x, c(1, 2, 2, 3))` but conveys your intent more clearly.

## Usage

``` r
exactly(x)
```

## Arguments

- x:

  A numeric vector.

## Value

The same as `rep(x, each = 2)`.

## Examples

``` r
chop(1:10, c(2, exactly(5), 8))
#>  [1] [1, 2)  [2, 5)  [2, 5)  [2, 5)  {5}     (5, 8)  (5, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [1, 2) [2, 5) {5} (5, 8) [8, 10]

# same:
chop(1:10, c(2, 5, 5, 8))
#>  [1] [1, 2)  [2, 5)  [2, 5)  [2, 5)  {5}     (5, 8)  (5, 8)  [8, 10] [8, 10]
#> [10] [8, 10]
#> Levels: [1, 2) [2, 5) {5} (5, 8) [8, 10]
```
