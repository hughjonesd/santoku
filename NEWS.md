# santoku (development version)

* New, experimental `chop_spikes()` and `dissect()` functions give 
  common values of `x` their own singleton intervals.
* New, experimental `tbar()` is a convenience function to print a barplot
  of data in the terminal window.
* On Unicode platforms, infinity will be represented as ∞ in breaks. Set
  `options(santoku.infinity = "Inf")` to use the old behaviour.
* Singleton breaks are not labelled specially by default in 
  `chop_quantiles(..., raw = FALSE)`. This means that e.g. if the 10th and 20th
  percentiles are both the same number, the label will still be `[10%, 20%]`.
* When multiple quantiles are the same, santoku warns and returns the leftmost
  quantile interval. Before it would merge the intervals, creating labels that
  might be different to what the user asked for.
* `chop_quantiles()` gains a `recalc_probs` argument. `recalc_probs = TRUE`
  recalculates probabilities using `ecdf(x)`, which may give more accurate 
  interval labels.
* `single = NULL` has been documented explicitly in `lbl_*` functions.
* Bugfix: `brk_manual()` no longer warns if `close_end = TRUE` (the default).


# santoku 1.0.0

* santoku is now considered stable.
* `chop_quantiles()` and `brk_quantiles()` gain a new `weights` argument, 
  letting you chop by weighted quantiles using `Hmisc::wtd.quantile()`.
* `brk_quantiles()` may now return singleton breaks, producing more
  accurate results when `x` has duplicate elements.
* Some deprecated functions have been removed, and the `raw` argument to 
  `lbl_*` functions now always gives a deprecation warning.
  
  
# santoku 0.10.0

* List arguments to `fmt` in `lbl_*` functions will be taken as arguments to
  `base::format`. This gives more flexibility in formatting, e.g., `units`
  breaks.
* `chop_n()` gains a `tail` argument, to deal with a last interval containing
  less than `n` elements. Set `tail = "merge"` to merge it with
  the previous interval. This guarantees that all intervals contain at least
  `n` elements.
* `chop_equally()` may return fewer than `groups` groups when there are 
  duplicate elements. We now warn when this happens.
* Bugfix: `chop_n()` could return intervals with fewer than `n` elements 
  when there were duplicate elements. The new algorithm avoids this, but
  may be slower in this case.

# santoku 0.9.1

* `endpoint_labels()` methods gain an unused `...` argument to satisfy R CMD CHECK.

# santoku 0.9.0

## Breaking changes

There are important changes to `close_end`.

* `close_end` is now `TRUE` by default in `chop()` and `fillet()`. 
  In previous versions:

  ```r
  chop(1:2, 1:2)
  ## [1] [1, 2) {2}   
  ## Levels: [1, 2) {2}  
  ```
  
  Whereas now:
  
  ```r
  chop(1:2, 1:2)
  ## [1] [1, 2] [1, 2]
  ## Levels: [1, 2]
  ```
  
  
* `close_end` is now always applied after `extend`. For example, in previous
  versions:
  
  ```r
  chop(1:4, 2:3, close_end = TRUE)
  ## [1] [1, 2) [2, 3] [2, 3] (3, 4]
  ## Levels: [1, 2) [2, 3] (3, 4]
  ```
  
  Whereas now:
  
  ```r
  chop(1:4, 2:3, close_end = TRUE)
  ## [1] [1, 2) [2, 3) [3, 4] [3, 4]
  ## Levels: [1, 2) [2, 3) [3, 4]
  ```

We changed this behaviour to be more in line with user expectations. 

* If `breaks` has names, they will be used as labels:
  
  ```r
  chop(1:5, c(Low = 1, Mid = 2, High = 4))
  ## [1] Low  Mid  Mid  High High
  ## Levels: Low Mid High  
  ```
  Names can also be used for labels in `probs` in `chop_quantiles()` and
  `proportions` in `chop_proportions()`.

* There is a new `raw` parameter to `chop()`. This replaces the parameter
  `raw` in `lbl_*` functions, which is now soft-deprecated.
  
* `lbl_manual()` is deprecated. Just use a vector argument to `labels` instead.

* A `labels` argument to `chop_quantiles()` now needs to be explicitly named.

I expect these to be the last important breaking changes before we release 
version 1.0 and mark the package as "stable". If they cause problems for you,
please file an issue.


## Other changes
* New `chop_fn()`, `brk_fn()` and `tab_fn()` chop using an arbitrary function.
* Added section on non-standard objects to vignette.


# santoku 0.8.0

## Breaking changes

* `lbl_endpoint()` has been renamed to `lbl_endpoints()`. The old version will
  trigger a deprecation warning. `lbl_endpoints()` gains `first`, `last` and
  `single` arguments like other labelling functions.
  
## Other changes

* New `chop_pretty()`, `brk_pretty()` and `tab_pretty()` functions use 
  `base::pretty()` to calculate attractive breakpoints. Thanks @davidhodge931.
* New `chop_proportions()`, `brk_proportions()` and `tab_proportions()`
  functions chop `x` into proportions of its range.
* `chop_equally()` now uses `lbl_intervals(raw = TRUE)` by default, bringing it
  into line with `chop_evenly()`, `chop_width()` and `chop_n()`.
* New `lbl_midpoints()` function labels breaks by their midpoints.
* `lbl_discrete()` gains a `single` argument.
* You can now chop `ts`, `xts::xts` and `zoo::zoo` objects.
* `chop()` is more forgiving when mixing different types, e.g.:
  - `Date` objects with `POSIXct` breaks, and vice versa
  - `bit64::integer64` and `double`s
* Bugfix: `lbl_discrete()` sometimes had ugly label formatting. 


# santoku 0.7.0

## Breaking changes

* In labelling functions, `first` and `last` arguments are now passed to 
  `glue::glue()`. Variables `l` and `r` represent the left and right endpoints 
  of the intervals. 
* `chop_mean_sd()` now takes a vector `sds` of standard deviations, rather than
  a single maximum number `sd` of standard deviations. Write e.g. 
  `chop_mean_sd(sds = 1:3)` rather than `chop_mean_sd(sd = 3)`. The `sd` argument
  is deprecated.
* The `groups` argument to `chop_evenly()`,  deprecated in 0.4.0, has 
  been removed.
* `brk_left()` and `brk_right()`, deprecated in 0.4.0, have been removed.
* `knife()`, deprecated in 0.4.0, has been removed.
* `lbl_format()`, questioning since 0.4.0, has been removed.
* Arguments of `lbl_dash()` and `lbl_intervals()` have been reordered for
  consistency with other labelling functions.

## Other changes

* You can now chop many more types, including `units` from the `units` package,
  `difftime` objects, `package_version` objects, etc. 
  - Character vectors will be chopped by lexicographic order, with an optional warning.
  - If you have problems chopping a vector type, file a bug report.
* The `{glue}` package has become a hard dependency. It is used in many places to 
  format labels. 
* There is a new `lbl_glue()` function using the `{glue}` package. Thanks to @dpprdan.
* You can now set `labels = NULL` to return integer codes.
* Arguments `first`, `last` and `single` can be used in `lbl_intervals()` 
  and `lbl_dash()`, to override the first and last interval labels, or to 
  label singleton intervals.
* `lbl_dash()` and `lbl_discrete()` use unicode em-dash where possible.
* `brk_default()` throws an error if breaks are not sorted.

  
## Bugfixes

* Bugfix: `tab()` and friends no longer display an `x` as the variable name.
* Bugfix: `lbl_endpoint()` was erroring for some types of breaks.



# santoku 0.6.0

* New arguments `first` and `last` in `lbl_dash()` and `lbl_discrete()` allow you 
  to override the first and last interval labels.

* Fixes for CRAN.

# santoku 0.5.0

* Negative numbers can be used in `chop_width()`.
  - This sets `left = FALSE` by default.
  - Also works for negative time intervals.
  
# santoku 0.4.1

* Bugfix: `chop(1:4, 1)` was erroring. 

# santoku 0.4.0

## Interface changes

The new version has some interface changes. These are based on user experience,
and are designed to make using `chop()` more intuitive and predictable.

* `chop()` has two new arguments, `left` and `close_end`.
  - Using `left = FALSE` is simpler and more intuitive than wrapping 
    breaks in `brk_right()`. 
  - `brk_left()` and `brk_right()` have been kept for now, but cannot be used to 
    wrap other break functions.
  - Using `close_end` is simpler than passing `close_end` into
    `brk_left()` or `brk_right()` (which no longer accept this argument directly).
  - `left = TRUE` by default, except for non-numeric objects in 
    `chop_quantiles()` and `chop_equally()`, where `left = FALSE` works better.
    
* `close_end` is now `FALSE` by default. 
  - This prevents user surprises when e.g. `chop(3, 1:3)` puts `3` into a 
    different category than `chop(3, 1:4)`.
  - `close_end` is `TRUE` by default for `chop_quantiles()`, `chop_n()` and 
    similar functions. This ensures that e.g. 
    `chop_quantiles(x, c(0, 1/3, 2/3, 1))` does what you would expect.

* The `groups` argument to `chop_evenly()` has been renamed from `groups` to
  `intervals`. This should make it easier to remember the difference between
  `chop_evenly()` and `chop_equally()`. (Chop evenly into `n` equal-width
  *intervals*, or chop equally into `n` equal-sized *groups*.)

* `knife()` has been deprecated to keep the interface slim and
  focused. Use `purrr::partial()` instead.



## Other changes

* Date and datetime (`POSIXct`) objects can now be chopped. 
  - `chop_width()` accepts `difftime`, `lubridate::period` or `lubridate::duration`
    objects
  - all other `chop_` functions work as well.
  
* Many labelling functions have a new `fmt` argument. This can be a string
  interpreted by `sprintf()` or `format()`, or a 1-argument formatting function
  for break endpoints, e.g. `scales::label_percent()`.
  
* Experimental: `lbl_discrete()` for discrete data such as integers or (most)
  dates.
  
* There is a new `lbl_endpoint()` function for labelling intervals solely by
  their left or right endpoint.

* `brk_mean_sd()` now accepts non-integer positive numbers.

* Add `brk_equally()` for symmetry with `chop_equally()`.

* Minor tweaks to `chop_deciles()`.

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
