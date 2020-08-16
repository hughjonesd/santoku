

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


test_that("brk_left, brk_right", {
  expect_identical(
          brk_res(brk_left(1:3)),
          santoku:::create_breaks(1:3, c(TRUE, TRUE, TRUE))
        )
  expect_identical(
          brk_res(brk_left(1:3), close_end = TRUE),
          santoku:::create_breaks(1:3, c(TRUE, TRUE, FALSE))
        )
  expect_identical(
          brk_res(brk_right(1:3)),
          santoku:::create_breaks(1:3, c(FALSE, FALSE, FALSE))
        )
  expect_identical(
          brk_res(brk_right(1:3), close_end = TRUE),
          santoku:::create_breaks(1:3, c(TRUE, FALSE, FALSE))
        )

  expect_false(
    anyNA(chop(1:5, brk_left(1:5)))
  )
})


test_that("brk_n", {
  for (i in 1:10) {
    x <- rnorm(sample(10:20, 1L))
    b <- sample(5L, 1L)
    expect_true(all(tab(!!x, brk_n(!!b), drop = TRUE) <= !!b),
          info = sprintf("length(x) %s b %s", length(x), b))
  }
})


test_that("bugfix: brk_n shouldn't error with too many non-unique values", {
  expect_error(brk_res(brk_n(2), c(1, 1, 1, 1, 5, 5, 5, 5)), regexp = NA)
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

  b <- brk_res(brk_width(-2, start = 2), 0:4)
  expect_identical(as.vector(b), c(-Inf, 0, 2, Inf))
})


test_that("brk_evenly", {
  b <- brk_res(brk_evenly(5), 0:10)
  expect_identical(as.vector(b), c(0, 2, 4, 6, 8, 10))
})


test_that("brk_mean_sd", {
  x <- rnorm(100)
  expect_silent(b <- brk_res(brk_mean_sd(3), x = x))
  m <- mean(x)
  sd <- sd(x)
  sd_ints <- seq(m - 3 * sd, m + 3 * sd, sd)
  expect_equal(as.numeric(b), sd_ints)

  expect_silent(brk_res(brk_mean_sd(3), x = rep(NA, 2)))
  expect_silent(brk_res(brk_mean_sd(3), x = rep(1, 3)))
  expect_silent(brk_res(brk_mean_sd(3), x = 1))
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
  expect_equivalent(c(brks), unique(quantile(x, 1:3/4)))
})


test_that("brk_equally", {
  expect_silent(brk_res(brk_equally(5)))
  expect_error(brk_equally(4.5))

  brks <- brk_res(brk_equally(3))
  expect_equivalent(brks, brk_res(brk_quantiles(0:3/3)))
})


test_that("printing", {
  b <- brk_left(1:3)
  expect_output(print(b))
  expect_silent(format(b))
  b_empty <- brk_left(1)
  expect_output(print(b_empty))
})

