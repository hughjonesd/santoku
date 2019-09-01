
test_that("brk_manual", {
  for (l in c(TRUE, FALSE)) for (r in c(TRUE, FALSE)) {
    expect_silent(x <- brk_manual(1:2, c(l, r)))
    expect_s3_class(x, "breaks")
  }

  expect_error(brk_manual(c(2, 2), c(TRUE, TRUE)))
  expect_error(brk_manual(c(2, 2), c(FALSE, TRUE)))
  expect_error(brk_manual(c(2, 2), c(FALSE, FALSE)))
  expect_silent(brk_manual(c(2, 2), c(TRUE, FALSE)))

  expect_error(brk_manual(1, c(TRUE, FALSE)))
  expect_error(brk_manual(1:2, c(TRUE)))
  expect_error(brk_manual("a", TRUE))
  expect_error(brk_manual(1, "c"))

  expect_error(brk_manual(c(1, NA), c(TRUE, TRUE)))
  expect_error(brk_manual(2:1, c(TRUE, TRUE)))

  expect_error(brk_manual(c(1, 2, 2, 2, 3), rep(TRUE, 5)),
        regexp = "equal")
})


test_that("brk_left, brk_right", {
  expect_identical(
          brk_left(1:3),
          brk_manual(1:3, c(TRUE, TRUE, FALSE))
        )
  expect_identical(
          brk_left(1:3, close_end = FALSE),
          brk_manual(1:3, c(TRUE, TRUE, TRUE))
        )
  expect_identical(
          brk_right(1:3),
          brk_manual(1:3, c(TRUE, FALSE, FALSE))
        )
  expect_identical(
          brk_right(1:3, close_end = FALSE),
          brk_manual(1:3, c(FALSE, FALSE, FALSE))
        )
})


test_that("brk_left/right wrappers", {
  expect_identical(
    brk_right(brk_manual(1:3, left = rep(TRUE, 3))),
    brk_right(1:3)
  )
  expect_identical(
    brk_left(brk_manual(1:3, left = rep(FALSE, 3))),
    brk_left(1:3)
  )
  expect_identical(
    brk_right(brk_manual(1:3, left = rep(TRUE, 3)), FALSE),
    brk_right(1:3, FALSE)
  )
  expect_identical(
    brk_left(brk_manual(1:3, left = rep(FALSE, 3)), FALSE),
    brk_left(1:3, FALSE)
  )
  expect_identical(
    brk_left(brk_quantiles(1:3/3))(1:10),
    brk_quantiles(1:3/3)(1:10)
  )
  expect_identical(
    brk_right(brk_quantiles(1:3/3))(1:10),
    brk_right(brk_quantiles(1:3/3)(1:10))
  )
  expect_identical(
    brk_left(brk_quantiles(1:3/3), FALSE)(1:10),
    brk_left(brk_quantiles(1:3/3)(1:10), FALSE)
  )
  expect_identical(
    brk_right(brk_quantiles(1:3/3), FALSE)(1:10),
    brk_right(brk_quantiles(1:3/3)(1:10), FALSE)
  )
})


test_that("brk_size", {
  for (i in 1:10) {
    x <- rnorm(sample(10:20, 1L))
    b <- sample(5L, 1L)
    expect_true(all(tab(!!x, brk_size(!!b), drop = TRUE) <= !!b),
          info = sprintf("length(x) %s b %s", length(x), b))
  }
})


test_that("brk_width", {
  b <- brk_width(1)(0.5:1.5)
  expect_equal(diff(as.vector(b)), 1)

  width <- runif(1)
  b <- brk_width(width)(0.5:1.5)
  bvec <- as.vector(b)
  expect_equal(diff(bvec)[1], width)
  expect_equal(bvec[1], 0.5)

  b <- brk_width(1)(rep(NA, 2))
  expect_identical(as.vector(b), numeric(0))

  b <- brk_width(1)(c(Inf, -Inf, NA))
  expect_identical(as.vector(b), numeric(0))

  b <- brk_width(1)(c(NA, 2, 4, NA))
  expect_equal(diff(as.vector(b))[1], 1)
})


test_that("brk_mean_sd", {
  x <- rnorm(10)
  expect_silent(b <- brk_mean_sd(3)(x))
  m <- mean(x)
  sd <- sd(x)
  sd_ints <- seq(m - 3 * sd, m + 3 * sd, sd)
  expect_equal(as.numeric(b), sd_ints)
})


test_that("printing", {
  b <- brk_left(1:3)
  expect_output(print(b))
  expect_silent(format(b))
  b_empty <- brk_left(1)
  expect_output(print(b_empty))
})
