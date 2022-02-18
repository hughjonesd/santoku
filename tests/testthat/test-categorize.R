
test_that("brk_manual", {
  expect_silent(brk_res(brk_manual(1:3, c(TRUE, TRUE, TRUE))))
  expect_silent(brk_res(brk_manual(c(1, 2, 2, 3), c(TRUE, TRUE, FALSE, TRUE))))
  expect_silent(brk_res(brk_manual(c(-Inf, 1, Inf), rep(TRUE, 3))))

  # singletons must have FALSE, TRUE
  expect_error(brk_res(brk_manual(c(1, 2, 2, 3), c(TRUE, FALSE, FALSE, TRUE))))
  # out of order:
  expect_error(brk_res(brk_manual(c(0, 3, 1), c(TRUE, TRUE, TRUE))))
})


test_that("categorize works", {

  x <- seq(0.5, 3.5, 0.5)

  breaks <- brk_res(brk_manual(1:3, c(TRUE, TRUE, TRUE)))
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, 1, 2, 2, NA, NA))

  breaks <- brk_res(brk_manual(1:3, c(TRUE, TRUE, FALSE)))
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, 1, 2, 2, 2, NA))

  breaks <- brk_res(brk_manual(c(1, 2, 2, 3), c(TRUE, TRUE, FALSE, TRUE)))
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, 1, 2, 3, NA, NA))

  x <- c(Inf, 1, -Inf, NA, NaN)
  breaks <- brk_res(brk_manual(1:3, c(TRUE, TRUE, TRUE)))
  r <- categorize(x, breaks)
  expect_equivalent(r, c(NA, 1, NA, NA, NA))
})


test_that("categorize_impl/categorize_non_numeric equivalence", {
  replicate(100, {
    n <- 10
    x <- rnorm(n) * 10

    breaks_pop <- c(-Inf, -5:5, Inf)
    b <- sort(sample(breaks_pop, n, replace = FALSE))
    left <- sample(c(TRUE, FALSE), n, replace = TRUE)
    x[c(3,5,7)] <- sample(breaks_pop, 3)

    b[3] <- b[2]
    b[8] <- b[7]
    left[2:3] <- left[7:8] <- c(TRUE, FALSE)

    ci <- categorize_impl(x, b, left)
    cnn <- categorize_non_numeric(x, b, left)
    expect_equal(ci, cnn)
  })
})
