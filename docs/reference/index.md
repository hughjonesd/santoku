# Package index

## Package overview

- [`santoku`](https://hughjonesd.github.io/santoku/reference/santoku-package.md)
  [`santoku-package`](https://hughjonesd.github.io/santoku/reference/santoku-package.md)
  : A versatile cutting tool for R: package overview and options

## Basic chop functions

Cut a vector into intervals

- [`chop()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  [`kiru()`](https://hughjonesd.github.io/santoku/reference/chop.md)
  [`tab()`](https://hughjonesd.github.io/santoku/reference/chop.md) :
  Cut data into intervals
- [`fillet()`](https://hughjonesd.github.io/santoku/reference/fillet.md)
  : Chop data precisely (for programmers)

## Chopping by width

Cut a vector into intervals defined by width

- [`brk_width(`*`<Duration>`*`)`](https://hughjonesd.github.io/santoku/reference/brk_width-for-datetime.md)
  : Equal-width intervals for dates or datetimes
- [`chop_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
  [`brk_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
  [`tab_width()`](https://hughjonesd.github.io/santoku/reference/chop_width.md)
  : Chop into fixed-width intervals
- [`chop_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md)
  [`brk_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md)
  [`tab_proportions()`](https://hughjonesd.github.io/santoku/reference/chop_proportions.md)
  : Chop into proportions of the range of x
- [`chop_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md)
  [`brk_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md)
  [`tab_evenly()`](https://hughjonesd.github.io/santoku/reference/chop_evenly.md)
  : Chop into equal-width intervals

## Chopping by n

Cut a vector into intervals defined by number of elements

- [`chop_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md)
  [`brk_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md)
  [`tab_n()`](https://hughjonesd.github.io/santoku/reference/chop_n.md)
  : Chop into fixed-sized groups
- [`chop_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  [`chop_deciles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  [`brk_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  [`tab_quantiles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  [`tab_deciles()`](https://hughjonesd.github.io/santoku/reference/chop_quantiles.md)
  : Chop by quantiles
- [`chop_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md)
  [`brk_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md)
  [`tab_equally()`](https://hughjonesd.github.io/santoku/reference/chop_equally.md)
  : Chop equal-sized groups

## Chopping and separating

Cut a vector into intervals, separating out common values

- [`chop_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md)
  [`brk_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md)
  [`tab_spikes()`](https://hughjonesd.github.io/santoku/reference/chop_spikes.md)
  : Chop common values into singleton intervals
- [`dissect()`](https://hughjonesd.github.io/santoku/reference/dissect.md)
  [`tab_dissect()`](https://hughjonesd.github.io/santoku/reference/dissect.md)
  : Cut data into intervals, separating out common values

## Other chop functions

Miscellaneous ways to cut a vector into intervals

- [`chop_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md)
  [`brk_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md)
  [`tab_mean_sd()`](https://hughjonesd.github.io/santoku/reference/chop_mean_sd.md)
  : Chop by standard deviations

- [`chop_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md)
  [`brk_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md)
  [`tab_pretty()`](https://hughjonesd.github.io/santoku/reference/chop_pretty.md)
  : Chop using pretty breakpoints

- [`chop_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md)
  [`brk_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md)
  [`tab_fn()`](https://hughjonesd.github.io/santoku/reference/chop_fn.md)
  : Chop using an existing function

- [`brk_default()`](https://hughjonesd.github.io/santoku/reference/brk_default.md)
  : Create a standard set of breaks

- [`brk_manual()`](https://hughjonesd.github.io/santoku/reference/brk_manual.md)
  :

  Create a `breaks` object manually

## Label functions

Specify how to label the chopped intervals

- [`lbl_dash()`](https://hughjonesd.github.io/santoku/reference/lbl_dash.md)
  : Label chopped intervals like 1-4, 4-5, ...

- [`lbl_discrete()`](https://hughjonesd.github.io/santoku/reference/lbl_discrete.md)
  : Label discrete data

- [`lbl_endpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md)
  [`lbl_endpoint()`](https://hughjonesd.github.io/santoku/reference/lbl_endpoints.md)
  : Label chopped intervals by their left or right endpoints

- [`lbl_glue()`](https://hughjonesd.github.io/santoku/reference/lbl_glue.md)
  :

  Label chopped intervals using the `glue` package

- [`lbl_intervals()`](https://hughjonesd.github.io/santoku/reference/lbl_intervals.md)
  : Label chopped intervals using set notation

- [`lbl_midpoints()`](https://hughjonesd.github.io/santoku/reference/lbl_midpoints.md)
  : Label chopped intervals by their midpoints

- [`lbl_seq()`](https://hughjonesd.github.io/santoku/reference/lbl_seq.md)
  : Label chopped intervals in sequence

## Miscellaneous

Other helper functions

- [`format(`*`<breaks>`*`)`](https://hughjonesd.github.io/santoku/reference/breaks-class.md)
  [`print(`*`<breaks>`*`)`](https://hughjonesd.github.io/santoku/reference/breaks-class.md)
  [`is.breaks()`](https://hughjonesd.github.io/santoku/reference/breaks-class.md)
  : Class representing a set of intervals
- [`exactly()`](https://hughjonesd.github.io/santoku/reference/exactly.md)
  : Define singleton intervals explicitly
- [`non-standard-types`](https://hughjonesd.github.io/santoku/reference/non-standard-types.md)
  : Tips for chopping non-standard types
- [`percent()`](https://hughjonesd.github.io/santoku/reference/percent.md)
  : Simple percentage formatter
