

# TODO

* tests
  - systematic tests for `brk_*` functions
  
* `brk_equally` for symmetry

* cut e.g. Dates, posixct, DateT
  - what else? ts, xts, zoo, lubridate classes
  - this is one for 0.2.0 I think
  - probably call it something like `chop_dates` rather than trying to
    do OO
  - `brk_days()`, `brk_weeks()` etc.? Equivalent to all lubridate's `days()` etc.
    classes? 
  - the basic `chop` function, with appropriate breaks, might already 
  "almost work" b/c it just uses arithmetic comparisons
  
* `chop_cleanly` - set `drop = FALSE`, `extend = FALSE/TRUE`? 
  - TRUE extend ensures no NAs from non-NA input
  - FALSE extend guarantees the number of levels (even if the breaks
    specified were infinite); not important if breaks are manually specified,
    but perhaps if e.g. `brk_mean_se` is called?
  

# Thoughts on errors

* On the whole, we don't want to error out if `x` is weird. `x` is data. But
  if e.g. `breaks` are weird, we can error out.
  - Exception: `x` is the wrong class or type.
  
* In some cases we want to guarantee the set of breaks.
  - e.g. `brk_left()`, `brk_manual()` with `extend` set.

* In other cases, e.g. `brk_evenly()` we don't need to make such a guarantee.



# Questions

* Do we need `drop`?

* Should we have a flag to return characters?
  - I'm skeptical, `forcats()` exists suggesting that factors aren't yet
    seen as worthless!
  
# Questions with a (provisional) answer

* When to extend?
  - I think default should be "if necessary" (`extend = NULL`); should always
    extend to Inf, -Inf so that these break labels are not data-dependent
  - Tension between wanting something predictable in your new data, vs. something
    readable in `tab_*`. E.g.
    ```r
    tab_size(1:9, 3, lbl_letters()) 
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

