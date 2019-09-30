
# santoku (development version)

* Changed `kut()` to `kiru()`. `kiru()` is an alternative spelling for `chop()`, 
  for use when the tidyr package is loaded.

# santoku 0.2.0

* Added a `NEWS.md` file to track changes to the package.
* Default labels when `extend = NULL` have changed, from
  `[-Inf, ...` and `..., Inf]` to `[min(x), ...` and `..., max(x)]`.
