# Changelog

## santoku 1.1.0

CRAN release: 2025-09-11

- Core logic has been speeded up using raw pointers. This was vibe-coded
  by me and Claude Code. If it breaks, please file a bug report.
- The experimental
  [`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md)
  and
  [`dissect()`](https://hughjonesd.github.io/santoku/reference/dissect.md)
  functions give common values of `x` their own singleton intervals.
- On Unicode platforms, infinity will be represented as ∞ in breaks. Set
  `options(santoku.infinity = "Inf")` to use the old behaviour.
- Singleton breaks are not labelled specially by default in
  `chop_quantiles(..., raw = FALSE)`. This means that e.g. if the 10th
  and 20th percentiles are both the same number, the label will still be
  `[10%, 20%]`.
- When multiple quantiles are the same, santoku warns and returns the
  leftmost quantile interval. Before it would merge the intervals,
  creating labels that might be different to what the user asked for.
- [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  gains a `recalc_probs` argument. `recalc_probs = TRUE` recalculates
  probabilities using `ecdf(x)`, which may give more accurate interval
  labels.
- `single = NULL` has been documented explicitly in `lbl_*` functions.
- Bugfix:
  [`brk_manual()`](https://hughjonesd.github.io/santoku/reference/brk_manual.md)
  no longer warns if `close_end = TRUE` (the default).

## santoku 1.0.0

CRAN release: 2024-06-04

- santoku is now considered stable.
- [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  and
  [`brk_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  gain a new `weights` argument, letting you chop by weighted quantiles
  using
  [`Hmisc::wtd.quantile()`](https://rdrr.io/pkg/Hmisc/man/wtd.stats.html).
- [`brk_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  may now return singleton breaks, producing more accurate results when
  `x` has duplicate elements.
- Some deprecated functions have been removed, and the `raw` argument to
  `lbl_*` functions now always gives a deprecation warning.

## santoku 0.10.0

CRAN release: 2023-10-12

- List arguments to `fmt` in `lbl_*` functions will be taken as
  arguments to [`base::format`](https://rdrr.io/r/base/format.html).
  This gives more flexibility in formatting, e.g., `units` breaks.
- [`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md)
  gains a `tail` argument, to deal with a last interval containing less
  than `n` elements. Set `tail = "merge"` to merge it with the previous
  interval. This guarantees that all intervals contain at least `n`
  elements.
- [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md)
  may return fewer than `groups` groups when there are duplicate
  elements. We now warn when this happens.
- Bugfix:
  [`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md)
  could return intervals with fewer than `n` elements when there were
  duplicate elements. The new algorithm avoids this, but may be slower
  in this case.

## santoku 0.9.1

CRAN release: 2023-03-08

- `endpoint_labels()` methods gain an unused `...` argument to satisfy R
  CMD CHECK.

## santoku 0.9.0

CRAN release: 2022-11-01

### Breaking changes

There are important changes to `close_end`.

- `close_end` is now `TRUE` by default in
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) and
  [`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md).
  In previous versions:

  ``` r
  chop(1:2, 1:2)
  ## [1] [1, 2) {2}   
  ## Levels: [1, 2) {2}  
  ```

  Whereas now:

  ``` r
  chop(1:2, 1:2)
  ## [1] [1, 2] [1, 2]
  ## Levels: [1, 2]
  ```

- `close_end` is now always applied after `extend`. For example, in
  previous versions:

  ``` r
  chop(1:4, 2:3, close_end = TRUE)
  ## [1] [1, 2) [2, 3] [2, 3] (3, 4]
  ## Levels: [1, 2) [2, 3] (3, 4]
  ```

  Whereas now:

  ``` r
  chop(1:4, 2:3, close_end = TRUE)
  ## [1] [1, 2) [2, 3) [3, 4] [3, 4]
  ## Levels: [1, 2) [2, 3) [3, 4]
  ```

We changed this behaviour to be more in line with user expectations.

- If `breaks` has names, they will be used as labels:

  ``` r
  chop(1:5, c(Low = 1, Mid = 2, High = 4))
  ## [1] Low  Mid  Mid  High High
  ## Levels: Low Mid High  
  ```

  Names can also be used for labels in `probs` in
  [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  and `proportions` in
  [`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md).

- There is a new `raw` parameter to
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md).
  This replaces the parameter `raw` in `lbl_*` functions, which is now
  soft-deprecated.

- [`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md)
  is deprecated. Just use a vector argument to `labels` instead.

- A `labels` argument to
  [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  now needs to be explicitly named.

I expect these to be the last important breaking changes before we
release version 1.0 and mark the package as “stable”. If they cause
problems for you, please file an issue.

### Other changes

- New
  [`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md),
  [`brk_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md)
  and
  [`tab_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md)
  chop using an arbitrary function.
- Added section on non-standard objects to vignette.

## santoku 0.8.0

CRAN release: 2022-06-08

### Breaking changes

- [`lbl_endpoint()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md)
  has been renamed to
  [`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md).
  The old version will trigger a deprecation warning.
  [`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md)
  gains `first`, `last` and `single` arguments like other labelling
  functions.

### Other changes

- New
  [`chop_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md),
  [`brk_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md)
  and
  [`tab_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md)
  functions use [`base::pretty()`](https://rdrr.io/r/base/pretty.html)
  to calculate attractive breakpoints. Thanks
  [@davidhodge931](https://github.com/davidhodge931).
- New
  [`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md),
  [`brk_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md)
  and
  [`tab_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md)
  functions chop `x` into proportions of its range.
- [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md)
  now uses `lbl_intervals(raw = TRUE)` by default, bringing it into line
  with
  [`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
  [`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
  and
  [`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md).
- New
  [`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md)
  function labels breaks by their midpoints.
- [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
  gains a `single` argument.
- You can now chop `ts`,
  [`xts::xts`](https://rdrr.io/pkg/xts/man/xts.html) and
  [`zoo::zoo`](https://rdrr.io/pkg/zoo/man/zoo.html) objects.
- [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) is
  more forgiving when mixing different types, e.g.:
  - `Date` objects with `POSIXct` breaks, and vice versa
  - [`bit64::integer64`](https://rdrr.io/pkg/bit64/man/bit64-package.html)
    and `double`s
- Bugfix:
  [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
  sometimes had ugly label formatting.

## santoku 0.7.0

CRAN release: 2022-03-18

### Breaking changes

- In labelling functions, `first` and `last` arguments are now passed to
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html).
  Variables `l` and `r` represent the left and right endpoints of the
  intervals.
- [`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md)
  now takes a vector `sds` of standard deviations, rather than a single
  maximum number `sd` of standard deviations. Write e.g. 
  `chop_mean_sd(sds = 1:3)` rather than `chop_mean_sd(sd = 3)`. The `sd`
  argument is deprecated.
- The `groups` argument to
  [`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md),
  deprecated in 0.4.0, has been removed.
- `brk_left()` and `brk_right()`, deprecated in 0.4.0, have been
  removed.
- `knife()`, deprecated in 0.4.0, has been removed.
- `lbl_format()`, questioning since 0.4.0, has been removed.
- Arguments of
  [`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md)
  and
  [`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md)
  have been reordered for consistency with other labelling functions.

### Other changes

- You can now chop many more types, including `units` from the `units`
  package, `difftime` objects, `package_version` objects, etc.
  - Character vectors will be chopped by lexicographic order, with an
    optional warning.
  - If you have problems chopping a vector type, file a bug report.
- The [glue](https://glue.tidyverse.org/) package has become a hard
  dependency. It is used in many places to format labels.
- There is a new
  [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  function using the [glue](https://glue.tidyverse.org/) package. Thanks
  to [@dpprdan](https://github.com/dpprdan).
- You can now set `labels = NULL` to return integer codes.
- Arguments `first`, `last` and `single` can be used in
  [`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md)
  and
  [`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md),
  to override the first and last interval labels, or to label singleton
  intervals.
- [`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md)
  and
  [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
  use unicode em-dash where possible.
- [`brk_default()`](https://hughjonesd.github.io/santoku/reference/brk_default.md)
  throws an error if breaks are not sorted.

### Bugfixes

- Bugfix:
  [`tab()`](https://hughjonesd.github.io/santoku/reference/chop.md) and
  friends no longer display an `x` as the variable name.
- Bugfix:
  [`lbl_endpoint()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md)
  was erroring for some types of breaks.

## santoku 0.6.0

CRAN release: 2021-11-04

- New arguments `first` and `last` in
  [`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md)
  and
  [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
  allow you to override the first and last interval labels.

- Fixes for CRAN.

## santoku 0.5.0

CRAN release: 2020-08-27

- Negative numbers can be used in
  [`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md).
  - This sets `left = FALSE` by default.
  - Also works for negative time intervals.

## santoku 0.4.1

CRAN release: 2020-06-16

- Bugfix: `chop(1:4, 1)` was erroring.

## santoku 0.4.0

CRAN release: 2020-06-09

### Interface changes

The new version has some interface changes. These are based on user
experience, and are designed to make using
[`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) more
intuitive and predictable.

- [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md) has
  two new arguments, `left` and `close_end`.

  - Using `left = FALSE` is simpler and more intuitive than wrapping
    breaks in `brk_right()`.
  - `brk_left()` and `brk_right()` have been kept for now, but cannot be
    used to wrap other break functions.
  - Using `close_end` is simpler than passing `close_end` into
    `brk_left()` or `brk_right()` (which no longer accept this argument
    directly).
  - `left = TRUE` by default, except for non-numeric objects in
    [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
    and
    [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md),
    where `left = FALSE` works better.

- `close_end` is now `FALSE` by default.

  - This prevents user surprises when e.g. `chop(3, 1:3)` puts `3` into
    a different category than `chop(3, 1:4)`.
  - `close_end` is `TRUE` by default for
    [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md),
    [`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md)
    and similar functions. This ensures that e.g. 
    `chop_quantiles(x, c(0, 1/3, 2/3, 1))` does what you would expect.

- The `groups` argument to
  [`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md)
  has been renamed from `groups` to `intervals`. This should make it
  easier to remember the difference between
  [`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md)
  and
  [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md).
  (Chop evenly into `n` equal-width *intervals*, or chop equally into
  `n` equal-sized *groups*.)

- `knife()` has been deprecated to keep the interface slim and focused.
  Use
  [`purrr::partial()`](https://purrr.tidyverse.org/reference/partial.html)
  instead.

### Other changes

- Date and datetime (`POSIXct`) objects can now be chopped.

  - [`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
    accepts `difftime`,
    [`lubridate::period`](https://lubridate.tidyverse.org/reference/period.html)
    or
    [`lubridate::duration`](https://lubridate.tidyverse.org/reference/duration.html)
    objects
  - all other `chop_` functions work as well.

- Many labelling functions have a new `fmt` argument. This can be a
  string interpreted by
  [`sprintf()`](https://rdrr.io/r/base/sprintf.html) or
  [`format()`](https://rdrr.io/r/base/format.html), or a 1-argument
  formatting function for break endpoints,
  e.g. [`scales::label_percent()`](https://scales.r-lib.org/reference/label_percent.html).

- Experimental:
  [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
  for discrete data such as integers or (most) dates.

- There is a new
  [`lbl_endpoint()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md)
  function for labelling intervals solely by their left or right
  endpoint.

- [`brk_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md)
  now accepts non-integer positive numbers.

- Add
  [`brk_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md)
  for symmetry with
  [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md).

- Minor tweaks to
  [`chop_deciles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md).

- Bugfix: `lbl_format()` wasn’t accepting numeric formats, even when
  `raw = TRUE`. Thanks to Sharla Gelfand.

## santoku 0.3.0

CRAN release: 2020-01-24

- First CRAN release.

- Changed `kut()` to
  [`kiru()`](https://hughjonesd.github.io/santoku/reference/chop.md).
  [`kiru()`](https://hughjonesd.github.io/santoku/reference/chop.md) is
  an alternative spelling for
  [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md),
  for use when the tidyr package is loaded.

- `lbl_sequence()` has become
  [`lbl_manual()`](https://hughjonesd.github.io/santoku/reference/lbl_manual.md).

- `lbl_letters()` and friends have been replaced by
  [`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md):

  - to replace `lbl_letters()` use
    [`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)
  - to replace `lbl_LETTERS()` use `lbl_seq("A")`
  - to replace `lbl_roman()` use `lbl_seq("i")`
  - to replace `lbl_ROMAN()` use `lbl_seq("I")`
  - to replace `lbl_numerals()` use `lbl_seq("1")`
  - for more complex formatting use e.g. `lbl_seq("A:")`,
    `lbl_seq("(i)")`

## santoku 0.2.0

- Added a `NEWS.md` file to track changes to the package.

- Default labels when `extend = NULL` have changed, from `[-Inf, ...`
  and `..., Inf]` to `[min(x), ...` and `..., max(x)]`.
