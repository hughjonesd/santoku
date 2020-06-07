# santoku (development version)

## Interface changes

The new version has some interface changes. These are based on user experience,
and are designed to make using `chop()` more intuitive and predictable.

* `chop()` has two new arguments, `left` and `close_end`.
  - Using `left = FALSE` is simpler and more intuitive than wrapping 
    breaks in `brk_right()`. 
  - `brk_left()` and `brk_right()` have been kept, but cannot be used to wrap
    other break functions.
  - Using `close_end` is simpler than passing `close_end` into
    `brk_left()` or `brk_right()` (which no longer accept this argument directly).
    
* `close_end` is now `FALSE` by default. 
  - This prevents user surprises when e.g. `chop(3, 1:3)` puts `3` into a 
    different category than `chop(3, 1:4)`.
  - `close_end` is `TRUE` by default for `chop_quantiles()`, `chop_n()` and 
    similar functions. This ensures that e.g. 
    `chop_quantiles(x, c(0, 1/3, 2/3, 1))` does what you would expect.

* The `groups` argument to `chop_evenly()` has been renamed from `groups` to
  `intervals`. This should make it easier to remember the difference between
  `chop_evenly()` and `chop_equally()`. (Chop evenly into `n` equal-sized 
  *intervals*, or chop equally into `n` equal-sized *groups*.)

* `knife()` has been deprecated to keep the interface slim and
  focused. Use `purrr::partial()` instead.
  
* Many labelling functions have a new `fmt` argument, to format break endpoints
  via `base::sprintf()`.


## Other changes

* Date and datetime (`POSIXct`) objects can now be chopped. 
  - `chop_width()` accepts `difftime`, `lubridate::period` or `lubridate::duration`
    objects
  - all other `chop_` functions work as well.

* Experimental: `lbl_discrete()` for discrete data such as integers or (most)
  dates.

* `brk_mean_sd()` now accepts non-integer positive numbers.

* Add `brk_equally()` for symmetry with `chop_equally()`.

* Minor tweaks to `chop_deciles()`.

* `lbl_format()` can now accept numeric sprintf formats (e.g. `"%.2f"`) 
  when `raw = FALSE`.

* Bugfix: `lbl_format()` wasn't accepting numeric formats, even when 
  `raw = TRUE`. Thanks to Sharla Gelfand.

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
