

# TODO

* tests
  - brk_mean_se and friends
  - weird input
  - weird breaks (1 or 0 length, 3 repeats...)
* chop_deciles etc?
* cut e.g. Dates
  - what else?



# Questions

* How to prevent duplicated labels?
  - Attempted by using %s for formats. But this leads to looong strings
  
* What to do with data-dependent breaks when there's an unexpected number
  of breaks? 
  - E.g. `chop_deciles(rep(NA, 5))`
  - Or indeed what if some quantiles are the same? e.g.
  `quantile(c(1, rep(2, 10), 3), c(.3, .6))`
  - answer is that corresponding label functions should deal with arbitrary 
    numbers of labels
  - the label function is the prob at the moment
    

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

# Other ideas

- Speedup categorize by only checking left intervals, add 1 if its past
  each interval;


