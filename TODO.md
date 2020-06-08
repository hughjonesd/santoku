

# TODO

## Pre 0.4.0


* Work on tests
  - tests for `left` and `close_end` arguments
  - tests for `brk_default`
  - probably use `brk_default` more than `brk_left/right`
  - `brk_width()` needs tests which match the guarantees in the documentation
  - ditto for `brk_evenly()` which now uses its own implementation to
    guarantee exactly `intervals` intervals
  - systematic tests for `brk_*` functions
  
* Try to integrate more of `brk_width.Period`, and call out to a generic
  only when necessary.
  - needs a good look anyway
  
* chop.Date issues:
  - Roll your own `seq` wrapper, which can dispatch on `period()`, `duration()`
    or `difftime()`? Then you'd probably be able to get rid of the `brk_width()`
    genericity.

* maybe `tab_equally`, `tab_n` (!) and `tab_quantiles` for symmetry reasons
  - `tab_quantiles` needs raw labels by default, to be useful

* implement an endpoint-formatter argument for `lbl_xxx` and friends? See #16 and
  https://stackoverflow.com/q/14456371/946850
  
* Do a presentation for dates and times


## Post 0.4.0

* DateTimes: 
  - work internally with anchored "Intervals"? Doing this beats just
    relying on e.g. `chop(months(x))` because we can e.g. start monthly 
    intervals on the 15th.
  - should we be able to chop by Intervals? This isn't `chop_width` because
    that isn't a fixed-in-time Interval; if you had a non-overlapping sequence
    of intervals you could chop with it. But you could equally just chop by
    the start times.
    
* Other things to cut
  - ts, xts, zoo, package_version, units?
  - `brk_days()`, `brk_weeks()` etc.? Equivalent to all lubridate's `days()` etc.
    classes? 
  

* Allow `brk_width()` to run backwards? See github feature request.


# Thoughts on errors

* On the whole, we don't want to error out if `x` is weird. `x` is data. But
  if e.g. `breaks` are weird, we can error out.
  - Exception: `x` is the wrong class or type.
  
* In some cases we want to guarantee the set of breaks.
  - e.g. `brk_left()`, `brk_manual()` with `extend` set.

* In other cases, e.g. `brk_evenly()` we don't need to make such a guarantee.


# Questions

* Is it really OK to have `left = FALSE` as the default in `chop_quantiles()`,
  `chop_evenly()` and friends? 
  - the alternative is to do it only when `x` is non-numeric.
  - that makes the surprise rarer, but rare surprises can be worse... and
    it adds complexity since the functions have to be generic.
  - another alternative: `chop` sets `left = FALSE` for non-numeric `x`. Probably
    better.

* Do we need `drop`?
  - should `drop` have a default of `! isTRUE(extend)` i.e. be `FALSE` when
    `extend = TRUE`?

* Should we have a flag to return characters?
  - I'm skeptical, `forcats()` exists suggesting that factors aren't yet
    seen as worthless!
  - Maybe have an `output = c("factor", "character", "numeric")` switch
  - If so, then `drop` should probably work even for numeric i.e. integer data
    by moving it down to start at 1

  
# Questions with a (provisional) answer


* Should we put a `percent` argument into `brk_quantiles()` so it can store 
  scaled endpoints as proportions rather than percentages (the current default)?
  - My sense is, not unless someone asks.
  - Oh, someone just did ask; more generally though.
  
* Should `close_end = TRUE` argument come before `...` in `chop_` variants?
  - No. We don't want people to set it by position, so distinguish it from
    the initial arguments.
    
* What to do about `tidyr::chop()`
  - Current answer: fuck 'em. (NB: just kidding. I am a huge tidyverse fan.) 
  - We provide `kiru()`. So on the REPL, people can just use `kiru()` if they
    load santoku first. If they load santoku second, they'll have to use
    `tidyr::chop()`, but reading the documentation, I suspect this will be rare.
  - For programming, people should probably used the fully qualified name 
    anyway.

* When to extend?
  - I think default should be "if necessary" (`extend = NULL`); should always
    extend to Inf, -Inf so that these break labels are not data-dependent
  - Tension between wanting something predictable in your new data, vs. something
    readable in `tab_*`. E.g.
    ```r
    tab_size(1:9, 3, lbl_seq()) 
    ```
    should surely return labels a, b, c. But this means we aren't always
    extending.
    
* Should we allow vector `labels` to be longer than necessary?
  + lets people do e.g. `chop(rnorm(100), -2:2, LETTERS)`
  - but might hide errors
  - overall I'm against
  
* Is the label interface right? Problem exposed by `brk_mean_sd`: if 
  we aren't sure whether data gets extended, then how do we know what
  the labels should be?
  - maybe label functions should have access to `x`?
  - or should they be informed if breaks got extended?
  - or could the breaks object know how to extend its labels?
  - current solution: labels get `extend`
  - I think better: `breaks` objects include suggested labels which
    the user can override. That way they always have the info necessary.
  - We could also divide labelling into two parts:
    1. choosing the break numbers (these may not be the actual values, e.g
      they could be quantiles or std errs from 0)
    2. formatting these numbers, and with dashes, set notation etc
  - So maybe `brk_*` functions always return break numbers;
    then labels decide how to format them?
  
* Should we automatically sort breaks, or throw an error if they're unsorted?
  - or a warning?
  - currently an error

* What if `breaks = c(1, 2, 2, 2, 3)`?
  - throw an error

* For some cases e.g. `brk_quantiles`, `brk_width`, the data may not work
  well e.g. if it is all NA. What is an empty set of breaks?


# Possible interfaces

- `hist_xxx` functions for histograms/barplots? (how to treat singletons?)
- `grp_xxx` for group_by? Hmmm...
- New label interface to replace `lbl_sequence`: 
  `lbl_style("1."), lbl_style("(i)"), lbl_style("A")` etc.? 
- Still wonder, could we drop `extend` which adds complexity and just
  have `only()` or `extend()` as new breaks functions?

# Other ideas

- Speedup categorize by only checking left intervals, add 1 if its past
  each interval [NO: actually no fewer checks in the end...]
- Speedup by using pointers? hmm, magic...

