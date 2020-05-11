library(bench)
library(dplyr)
library(ggplot)
library(Hmisc)
library(santoku)
bench_categorize <- bench::press(
  xlen = 10 ^ c(3:5),
  nbreaks = 5 * 10^(0:3),
  {
    x <- runif(xlen)
    breaks <- seq(0, 1, 1/nbreaks)
    attr(breaks, "left") <- rep(TRUE, length(breaks))
    bench::mark(
      new_chop = chop(x, breaks),
      new_cat  = santoku:::categorize(x, breaks),
      old_cat  = santoku:::old_categorize(x, breaks),
      cut  = cut(x, breaks),
      cut2 = cut2(x, breaks),
      check = FALSE
    )
})

bench_categorize %>%
      filter(nbreaks <100) %>%
      as_tibble() %>%
      ggpplot() + facet_grid(scales = "free")
