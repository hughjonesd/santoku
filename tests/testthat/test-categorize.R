
test_that("brk_manual", {
  expect_silent(brk_manual(1:3, c(TRUE, TRUE, TRUE))(1, FALSE))
  expect_silent(brk_manual(c(1, 2, 2, 3), c(TRUE, TRUE, FALSE, TRUE))(1, FALSE))
  expect_silent(brk_manual(c(-Inf, 1, Inf), rep(TRUE, 3))(1, FALSE))

  # singletons must have FALSE, TRUE
  expect_error(brk_manual(c(1, 2, 2, 3), c(TRUE, FALSE, FALSE, TRUE))(1, FALSE))
  # out of order:
  expect_error(brk_manual(c(0, 3, 1), c(TRUE, TRUE, TRUE))(1, FALSE))
})


test_that("categorize works", {

  x <- seq(0.5, 3.5, 0.5)

  breaks <- brk_manual(1:3, c(TRUE, TRUE, TRUE))(1, FALSE)
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, 1, 2, 2, NA, NA))

  breaks <- brk_manual(1:3, c(TRUE, TRUE, FALSE))(1, FALSE)
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, 1, 2, 2, 2, NA))

  breaks <- brk_manual(c(1, 2, 2, 3), c(TRUE, TRUE, FALSE, TRUE))(1, FALSE)
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, 1, 2, 3, NA, NA))

  x <- c(Inf, 1, -Inf, NA, NaN)
  breaks <- brk_manual(1:3, c(TRUE, TRUE, TRUE))(1, FALSE)
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, NA, NA, NA))
})
