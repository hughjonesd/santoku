

# TODO

* tests
  - brk_mean_se and friends
  - weird input
  - weird breaks (1 or 0 length, 3 repeats...)
* chop_deciles etc?



# Questions

* How to prevent duplicated labels?

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

* can we cut e.g. Dates?

* Should we automatically sort breaks, or throw an error if they're unsorted?
  - or a warning?

* What if `breaks = c(1, 2, 2, 2, 3)`?

* For some cases e.g. `brk_quantiles`, `brk_width`, the data may not work
  well e.g. if it is all NA. What is an empty set of breaks?


# Possible interfaces

- `hist_xxx` functions for histograms/barplots? (how to treat singletons?)
- `grp_xxx` for group_by? Hmmm...

# Other ideas

- Speedup categorize by only checking left intervals, add 1 if its past
  each interval;


