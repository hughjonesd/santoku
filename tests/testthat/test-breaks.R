

test_that("brk_manual", {
  for (l in c(TRUE, FALSE)) for (r in c(TRUE, FALSE)) {
    expect_silent(x <- brk_res(brk_manual(1:2, c(l, r))))
    expect_s3_class(x, "breaks")
  }

  expect_error(brk_res(brk_manual(c(2, 2), c(TRUE, TRUE))))
  expect_error(brk_res(brk_manual(c(2, 2), c(FALSE, TRUE))))
  expect_error(brk_res(brk_manual(c(2, 2), c(FALSE, FALSE))))
  expect_silent(brk_res(brk_manual(c(2, 2), c(TRUE, FALSE))))

  expect_error(brk_res(brk_manual(1, c(TRUE, FALSE))))
  expect_error(brk_res(brk_manual(1:2, c(TRUE))))
  expect_error(brk_res(brk_manual("a", TRUE)))
  expect_error(brk_res(brk_manual(1, "c")))

  expect_error(brk_res(brk_manual(c(1, NA), c(TRUE, TRUE))))
  expect_error(brk_res(brk_manual(2:1, c(TRUE, TRUE))))

  expect_error(brk_res(brk_manual(c(1, 2, 2, 2, 3), rep(TRUE, 5))),
        regexp = "equal")
})


test_that("brk_n", {
  for (i in 1:10) {
    x <- rnorm(sample(10:20, 1L))
    b <- sample(5L, 1L)
    expect_true(all(tab(!!x, brk_n(!!b), drop = TRUE) <= !!b),
          info = sprintf("length(x) %s b %s", length(x), b))
    # right-closed breaks
    expect_true(all(tab(!!x, brk_n(!!b), drop = TRUE, left = FALSE) <= !!b),
                info = sprintf("length(x) %s b %s left = FALSE", length(x), b))
  }

  # test with duplicates in x
  for (i in 1:10) {
    x <- rnorm(10)
    x <- sample(x, replace = TRUE)
    b <- sample(5L, 1L)
    tbl <- tab(x, brk_n(b), drop = TRUE)
    # all but the last category should have size >= b
    expect_true(all(tbl[-length(tbl)] >= b),
          info = sprintf("length(x) %s b %s", length(x), b))
    # right-closed breaks
    tbl <- tab(x, brk_n(b), drop = TRUE, left = FALSE)
    expect_true(all(tbl[-1] >= b),
          info = sprintf("length(x) %s b %s", length(x), b))
  }
})


test_that("brk_n, tail = 'merge'", {
  x <- 1:5
  res <- brk_res(brk_n(3, tail = "merge"), x = x)
  expect_equal(as.vector(tab(x, res)), 5)

  x <- 1:6
  res <- brk_res(brk_n(3, tail = "merge"), x = x)
  expect_equal(as.vector(tab(x, res)), c(3, 3))

  x <- 1:7
  res <- brk_res(brk_n(3, tail = "merge"), x = x)
  expect_equal(as.vector(tab(x, res)), c(3, 4))

  x <- c(1, 1, 1, 2, 2)
  res <- brk_res(brk_n(3, tail = "merge"), x = x)
  expect_equal(as.vector(tab(x, res)), 5)

  x <- c(1, 1, 1, 2, 2, 2)
  res <- brk_res(brk_n(3, tail = "merge"), x = x)
  expect_equal(as.vector(tab(x, res)), c(3, 3))

  x <- c(1, 1, 1, 2, 2, 2, 2)
  res <- brk_res(brk_n(3, tail = "merge"), x = x)
  expect_equal(as.vector(tab(x, res)), c(3, 4))
})


test_that("bugfix: brk_n shouldn't error with too many non-unique values", {
  expect_error(
    brk_res(brk_n(2), x = c(1, 1, 1, 1, 5, 5, 5, 5)),
    regexp = NA
  )
})


test_that("bugfix: brk_n shouldn't take too few elems after non-unique values", {
  x <- c(1, 1, 1, 1, 2, 3, 4)
  res <- brk_res(brk_n(3), x = x)
  expect_equal(as.vector(tab(x, res)), c(4, 3))

  x <- c(1, 2, 3, 3, 4, 5, 6)
  res <- brk_res(brk_n(3), x = x)
  expect_equal(as.vector(tab(x, res)), c(4, 3))

  x <- c(1, 2, 3, 3, 4)
  res <- brk_res(brk_n(2), x = x)
  expect_equal(as.vector(tab(x, res)), c(2, 2, 1))
})


test_that("brk_width", {
  b <- brk_res(brk_width(1), 0.5:1.5)
  expect_equal(diff(as.vector(b)), 1)

  width <- runif(1)
  b <- brk_res(brk_width(width), 0.5:1.5)
  bvec <- as.vector(b)
  expect_equal(diff(bvec)[1], width)
  expect_equal(bvec[1], 0.5)

  b <- brk_res(brk_width(1), rep(NA, 2))
  expect_identical(as.vector(b), c(-Inf, Inf))

  b <- brk_res(brk_width(1), c(Inf, -Inf, NA))
  expect_identical(as.vector(b), c(-Inf, Inf))

  b <- brk_res(brk_width(1), c(NA, 2, 4, NA))
  expect_equal(diff(as.vector(b))[1], 1)
})


test_that("brk_width, negative width", {
  b <- brk_res(brk_width(-1), 0.5:1.5)
  expect_equal(diff(as.vector(b)), 1)

  width <- runif(1, min = -1, max = 0)
  b <- brk_res(brk_width(width), 0.5:1.5)
  bvec <- as.vector(b)
  expect_equal(diff(bvec)[1], -width)
  expect_equal(bvec[length(bvec)], 1.5)

  b <- brk_res(brk_width(-2, start = 2.5), 0:4)
  expect_identical(as.vector(b), c(-1.5, 0.5, 2.5))
})


test_that("brk_evenly", {
  b <- brk_res(brk_evenly(5), 0:10)
  expect_identical(as.vector(b), c(0, 2, 4, 6, 8, 10))
})


test_that("brk_proportions", {
  b <- brk_res(brk_proportions(c(0.2, 0.8)), 0:10)
  expect_identical(as.vector(b), c(2, 8))

  expect_error(brk_proportions(c(0, 1, 2)))
  expect_error(brk_proportions(c(-1, 0.5)))
  expect_error(brk_proportions(c(0.5, NA)))
})


test_that("brk_mean_sd", {
  x <- rnorm(100)
  expect_silent(b <- brk_res(brk_mean_sd(1:3), x = x))
  m <- mean(x)
  sd <- sd(x)
  sd_ints <- seq(m - 3 * sd, m + 3 * sd, sd)
  expect_equal(as.numeric(b), sd_ints)

  expect_silent(brk_res(brk_mean_sd(1:3), x = rep(NA, 2)))
  expect_silent(brk_res(brk_mean_sd(1:3), x = rep(1, 3)))
  expect_silent(brk_res(brk_mean_sd(1:3), x = 1))

  lifecycle::expect_deprecated(res <- brk_res(brk_mean_sd(sd = 3)))
  expect_equivalent(
    res, brk_res(brk_mean_sd(1:3))
  )
})


test_that("brk_quantiles", {
  expect_silent(brk_res(brk_quantiles(1:3/4)))

  x <- 1:10
  brks <- brk_quantiles(1:3/4)(x, FALSE, TRUE, FALSE)
  expect_equivalent(c(brks), quantile(x, 1:3/4))

  expect_silent(brks <- brk_quantiles(numeric(0))(x, TRUE, TRUE, FALSE))
  expect_equivalent(c(brks), c(-Inf, Inf))

  x <- rep(1, 5)
  brks <- brk_quantiles(1:3/4)(x, FALSE, TRUE, FALSE)
  expect_equivalent(c(brks), c(1, 1))

  x <- 1:10
  brks <- brk_quantiles(1:3/4, weights = 1:10)(x, FALSE, TRUE, FALSE)
  expect_equivalent(c(brks), Hmisc::wtd.quantile(x, weights = 1:10, probs = 1:3/4))
})


test_that("bugfix #49: brk_quantiles() shouldn't ignore duplicate quantiles", {
  x <- c(1, 1, 2, 3, 4)
  brks <- brk_quantiles(0:5/5)(x, FALSE, TRUE, FALSE)
  expect_equivalent(c(brks), c(1.0, 1.0, 1.6, 2.4, 3.2, 4.0))

  x <- c(1, 1, 1, 2, 3)
  brks <- brk_quantiles(0:5/5)(x, FALSE, TRUE, FALSE)
  expect_equivalent(c(brks), c(1.0, 1.0, 1.4, 2.2, 3.0))
})


test_that("brk_equally", {
  expect_silent(brk_res(brk_equally(5)))
  expect_error(brk_equally(4.5))

  brks <- brk_res(brk_equally(3))
  expect_equivalent(brks, brk_res(brk_quantiles(0:3/3)))
})


test_that("brk_equally warns when too few breaks created", {
  dupes <- rep(1, 4)
  expect_warning(brk_res(brk_equally(4), x = dupes))
})


test_that("brk_pretty", {
  expect_silent(brks <- brk_res(brk_pretty(5), x = 1:10))
  expect_equivalent(brks, brk_res(brk_default(pretty(1:10)), x = 1:10))

  expect_silent(brks2 <- brk_res(brk_pretty(5, high.u.bias = 0), x = 1:10))
  expect_equivalent(
    brks2,
    brk_res(brk_default(pretty(1:10, high.u.bias = 0)), x = 1:10)
  )
})


test_that("brk_fn", {
  x <- 1:10
  expect_silent(
    brks <- brk_res(brk_fn(scales::breaks_extended(5)), x = x)
  )
  expect_equivalent(
    brks,
    brk_res(brk_default(scales::breaks_extended(5)(x)))
  )

  expect_silent(
    brks2 <- brk_res(brk_fn(pretty, n = 10), x = x)
  )
  expect_equivalent(
    brks2,
    brk_res(brk_default(pretty(x, n = 10)), x = x)
  )
})


test_that("printing", {
  b <- brk_res(brk_default(1:3))
  expect_output(print(b))
  expect_silent(format(b))
  b_empty <- brk_res(brk_default(1))
  expect_output(print(b_empty))
})

