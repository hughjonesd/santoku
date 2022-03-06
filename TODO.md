

# TODO

* Work on tests
  - tests for `left` and `close_end` arguments
  - tests for `brk_default`
  - `brk_width()` needs tests which match the guarantees in the documentation
  - ditto for `brk_evenly()` which now uses its own implementation to
    guarantee exactly `intervals` intervals
  - systematic tests for `brk_*` functions
  

* Implement a simple `Infinity` class that automatically casts to any other
  class and is always > or < than any other element? Then replace the `class_bounds()`
  complexity?
  - The problem at the moment is that `vec_cast()` is highly unreliable and
    you never know if a particular class will accept `Inf`.
  - An infinity class would be fine, but how does that go into the existing
    `breaks` object which has its own underlying class?
  - Might be more reasonable just not to add `Inf` or `-Inf` elements. Instead,
    record whether the breaks have left and right "infinity" set. Then just
    add numeric infinity to the breaks before you call `categorize_impl` (or
    the R version). In particular, e.g. `integer64` doesn't like `Inf` or `-Inf`
    but it does have very large numbers in `bit64::lim.integer64` which look
    ugly and which only exist to be lower/higher than everything else anyway...
    - But NB this requires a new way to create the labels, and that kinda 
      sucks....


# Thoughts on errors

* On the whole, we don't want to error out if `x` is weird. `x` is data. But
  if e.g. `breaks` are weird, we can error out.
  - Exception: `x` is the wrong class or type.
  
* In some cases we want to guarantee the set of breaks.
  - e.g. `brk_manual()` with `extend` set.

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


# Questions with a (provisional) answer

* Should we have a flag to return characters?
  - No, we have `labels = NULL` for integer codes only though.

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

