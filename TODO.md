

# TODO

* tests
* README

# Questions

* what about NAs? NaN?
  - presumably they become NA
  - NA category

* can we cut e.g. Dates?

* Should we automatically sort breaks, or throw an error if they're unsorted?
  - or a warning?

* For some cases e.g. `brk_quantiles`, `brk_width`, the data may not work
  well e.g. if it is all NA. What is an empty set of breaks?


# Possible interfaces

- `hist_xxx` functions for histograms/barplots? (how to treat singletons?)
- `grp_xxx` for group_by? Hmmm...

# Other ideas

- Speedup categorize by only checking left intervals, add 1 if its past
  each interval;


