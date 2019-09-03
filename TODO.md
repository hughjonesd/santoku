

# TODO

* tests
  - brk_mean_se and friends
  - weird input
  - weird breaks (1 or 0 length, 3 repeats...)
* cut e.g. Dates
  - what else?

## New labels plan

* breaks *may* return their own labels
* these are overridden if labels are provided explicitly
* if not, and if they don't return labels, use the default `lbl_intervals`
* internal functions to style break-names
* make sure that non-standard intervals are always clear e.g.
  do `-1 s.d. - 0 .s.d` for `brk_mean_se`.
  
* note that breaks which can be nested must deal with existing labels.
  - e.g. what if you do `brk_right(brk_quantiles())`
  - then again, does anyone actually want to do quantiles-with-right-breaks?

* Problem: currently, breaks get extended in `chop`. This now means that
  labels must be extended....
  - Solution: different kinds of breaks are subclasses, have their own 
  `labels` method? This then gets called after the breaks are extended. Heavy...
  - `breaks` functions all call a common function to see if they need to extend
    themselves? 
    
    then gets called

# Questions

* How to prevent duplicated labels?
  - Right now, first tries `format`, then tries increasing numbers of digits
  - I think when you manually specify breaks, you'd want to see them as you
    entered them.
  - When they are created by e.g. `chop_size`, we could be more relaxed about
    trimming them to fewer digits (so skip the use of `format`)....
  
* What to do with data-dependent breaks when there's an unexpected number
  of breaks? 
  - E.g. `chop_deciles(rep(NA, 5))`
  - Or indeed what if some quantiles are the same? e.g.
  `quantile(c(1, rep(2, 10), 3), c(.3, .6))`
  - answer is that corresponding label functions should deal with arbitrary 
    numbers of labels
  - the label function is the prob at the moment

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
  
# Questions with an attempted answer

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

