
test_that("basic functionality", {
  k <- knife(breaks = 1:3)
  x <- 0.5 + 1:3
  expect_equivalent(k(x), kut(x, breaks = 1:3))

  k <- knife(breaks = brk_quantiles(0.5))
  expect_equivalent(k(x), kut(x, breaks = brk_quantiles(0.5)))
  y <- c(1, 4, 7, 10, 15)
  expect_equivalent(k(y), kut(y, breaks = brk_quantiles(0.5)))


  k2 <- knife(breaks = 1:3, labels = lbl_numerals())
  x <- 0.5 + 1:3
  expect_equivalent(k2(x), kut(x, breaks = 1:3, labels = lbl_numerals()))
})


test_that("arguments preserved across environments", {
  y <- c(1, 4, 7, 10, 15)
  qs <- 0.5
  k <- knife(breaks = brk_quantiles(qs))
  qs <- c(0.25, 0.75)
  expect_equivalent(k(y), kut(y, breaks = brk_quantiles(0.5)))

  f <- function () {
    qs <- c(0.25, 0.75)
    k(y)
  }
  expect_equivalent(f(), kut(y, breaks = brk_quantiles(0.5)))
})
