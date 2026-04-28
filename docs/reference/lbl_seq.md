# Label chopped intervals in sequence

`lbl_seq()` labels intervals sequentially, using numbers or letters.

## Usage

``` r
lbl_seq(start = "a")
```

## Arguments

- start:

  String. A template for the sequence. See below.

## Value

A function that creates a vector of labels.

## Details

`start` shows the first element of the sequence. It must contain exactly
*one* character out of the set "a", "A", "i", "I" or "1". For later
elements:

- "a" will be replaced by "a", "b", "c", ...

- "A" will be replaced by "A", "B", "C", ...

- "i" will be replaced by lower-case Roman numerals "i", "ii", "iii",
  ...

- "I" will be replaced by upper-case Roman numerals "I", "II", "III",
  ...

- "1" will be replaced by numbers "1", "2", "3", ...

Other characters will be retained as-is.

## See also

Other labelling functions:
[`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md),
[`lbl_date()`](https://hughjonesd.github.io/santoku/reference/lbl_datetime.md),
[`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md),
[`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md),
[`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md),
[`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md),
[`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md),
[`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md)

## Examples

``` r
chop(1:10, c(2, 5, 8), lbl_seq())
#>  [1] a b b b c c c d d d
#> Levels: a b c d

chop(1:10, c(2, 5, 8), lbl_seq("i."))
#>  [1] i.   ii.  ii.  ii.  iii. iii. iii. iv.  iv.  iv. 
#> Levels: i. ii. iii. iv.

chop(1:10, c(2, 5, 8), lbl_seq("(A)"))
#>  [1] (A) (B) (B) (B) (C) (C) (C) (D) (D) (D)
#> Levels: (A) (B) (C) (D)
```
