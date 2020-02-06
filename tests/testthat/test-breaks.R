

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
          santoku:::create_breaks(1:3, c(TRUE, TRUE, FALSE))
        )
  expect_identical(
          brk_res(brk_left(1:3, close_end = FALSE)),
          santoku:::create_breaks(1:3, c(TRUE, TRUE, TRUE))
        )
  expect_identical(
          brk_res(brk_right(1:3)),
          santoku:::create_breaks(1:3, c(TRUE, FALSE, FALSE))
        )
  expect_identical(
          brk_res(brk_right(1:3, close_end = FALSE)),
          santoku:::create_breaks(1:3, c(FALSE, FALSE, FALSE))
        )

  expect_false(
    anyNA(chop(1:5, brk_left(1:5, FALSE)))
  )
})


test_that("brk_left/right wrappers", {
  expect_identical(
    brk_res(brk_right(brk_manual(1:3, left = rep(TRUE, 3)))),
    brk_res(brk_right(1:3))
  )
  expect_identical(
    brk_res(brk_left(brk_manual(1:3, left = rep(FALSE, 3)))),
    brk_res(brk_left(1:3))
  )
  expect_identical(
    brk_res(brk_right(brk_manual(1:3, left = rep(TRUE, 3)), FALSE)),
    brk_res(brk_right(1:3, FALSE))
  )
  expect_identical(
    brk_res(brk_left(brk_manual(1:3, left = rep(FALSE, 3)), FALSE)),
      brk_res(brk_left(1:3, FALSE))
  )
  expect_identical(
    brk_res(brk_left(brk_quantiles(1:3/3))),
    brk_res(brk_quantiles(1:3/3))
  )
})


test_that("brk_left/right wrappers don't affect `extend`-ed breaks", {
  x <- 0:100
  for (f in list(brk_left, brk_right)) {
    wrapped_brk <- f(brk_quantiles(1:3/4))
    ext_FALSE <- wrapped_brk(x, extend = FALSE)
    ext_TRUE  <- wrapped_brk(x, extend = TRUE)
    ext_NULL  <- wrapped_brk(x, extend = NULL)
    expect_identical(attr(ext_FALSE, "left")[1], attr(ext_TRUE, "left")[2])
    expect_identical(attr(ext_FALSE, "left")[1], attr(ext_NULL, "left")[2])
    lnF <- length(ext_FALSE)
    lnT <- length(ext_TRUE)
    expect_identical(attr(ext_FALSE, "left")[lnF], attr(ext_TRUE, "left")[lnT - 1])
    expect_identical(attr(ext_FALSE, "left")[lnF], attr(ext_NULL, "left")[lnT - 1])
  }
})


test_that("brk_n", {
  for (i in 1:10) {
    x <- rnorm(sample(10:20, 1L))
    b <- sample(5L, 1L)
    expect_true(all(tab(!!x, brk_n(!!b), drop = TRUE) <= !!b),
          info = sprintf("length(x) %s b %s", length(x), b))
  }
})


test_that("brk_width", {
  b <- brk_width(1)(0.5:1.5, FALSE)
  expect_equal(diff(as.vector(b)), 1)

  width <- runif(1)
  b <- brk_width(width)(0.5:1.5, FALSE)
  bvec <- as.vector(b)
  expect_equal(diff(bvec)[1], width)
  expect_equal(bvec[1], 0.5)

  b <- brk_width(1)(rep(NA, 2), FALSE)
  expect_identical(as.vector(b), c(-Inf, Inf))

  b <- brk_width(1)(c(Inf, -Inf, NA), FALSE)
  expect_identical(as.vector(b), c(-Inf, Inf))

  b <- brk_width(1)(c(NA, 2, 4, NA), FALSE)
  expect_equal(diff(as.vector(b))[1], 1)
})


test_that("brk_evenly", {
  expect_identical(
          brk_evenly(5)(0:10, FALSE),
          brk_width(2)(0:10, FALSE)
        )
})


test_that("brk_mean_sd", {
  x <- rnorm(100)
  expect_silent(b <- brk_mean_sd(3)(x, FALSE))
  m <- mean(x)
  sd <- sd(x)
  sd_ints <- seq(m - 3 * sd, m + 3 * sd, sd)
  expect_equal(as.numeric(b), sd_ints)

  b <- brk_mean_sd(1)(x, NULL)
  expect_equal(
          attr(b, "break_labels"),
          c("-Inf", "-1 sd", "0 sd", "1 sd", "Inf")
        )

  expect_silent(brk_mean_sd(3)(rep(NA, 2), FALSE))
  expect_silent(brk_mean_sd(3)(rep(1, 3), FALSE))
  expect_silent(brk_mean_sd(3)(1, FALSE))
})


test_that("brk_quantiles", {
  expect_silent(brk_res(brk_quantiles(1:3/4)))

  x <- 1:10
  brks <- brk_quantiles(1:3/4)(x, FALSE)
  expect_equivalent(c(brks), quantile(x, 1:3/4))

  expect_silent(brks <- brk_quantiles(numeric(0))(x, TRUE))
  expect_equivalent(c(brks), c(-Inf, Inf))

  x <- rep(1, 5)
  brks <- brk_quantiles(1:3/4)(x, FALSE)
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


test_that("systematic tests", {
  # input of normal; unsorted; with NA; with +-Inf; only 1 break;
  # non-numeric; length 0

})
