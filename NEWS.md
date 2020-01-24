# santoku (development version)


# santoku 0.3.0

* First CRAN release.
* Changed `kut()` to `kiru()`. `kiru()` is an alternative spelling for `chop()`, 
  for use when the tidyr package is loaded.
* `lbl_sequence()` has become `lbl_manual()`.
* `lbl_letters()` and friends have been replaced by `lbl_seq()`:
  - to replace `lbl_letters()` use `lbl_seq()`
  - to replace `lbl_LETTERS()` use `lbl_seq("A")`
  - to replace `lbl_roman()` use `lbl_seq("i")`
  - to replace `lbl_ROMAN()` use `lbl_seq("I")`
  - to replace `lbl_numerals()` use `lbl_seq("1")`
  - for more complex formatting use e.g. `lbl_seq("A:")`, `lbl_seq("(i)")`

# santoku 0.2.0

* Added a `NEWS.md` file to track changes to the package.
* Default labels when `extend = NULL` have changed, from
  `[-Inf, ...` and `..., Inf]` to `[min(x), ...` and `..., max(x)]`.
