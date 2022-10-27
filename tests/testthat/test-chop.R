
test_that("basic functionality", {
  x <- 1:3
  lbrks <- brk_manual(1:3, rep(TRUE, 3))
  rbrks <- brk_manual(1:3, rep(FALSE, 3))
  rc_brks <- brk_manual(1:3, c(TRUE, TRUE, FALSE))

  expect_equivalent(
    chop(x, lbrks, lbl_seq("1"), extend = FALSE, close_end = FALSE),
    factor(c(1, 2, NA))
  )
  expect_equivalent(
    chop(x, rbrks, lbl_seq("1"), extend = FALSE, close_end = FALSE),
    factor(c(NA, 1, 2))
  )
  expect_equivalent(
    chop(x, rc_brks, lbl_seq("1"), extend = FALSE, close_end = FALSE),
    factor(c(1, 2, 2))
  )


})


test_that("NA, NaN and Inf", {
  y <- c(1:3, NA, NaN)
  expect_equivalent(
    chop(y, 1:3, lbl_seq("1"), extend = FALSE, close_end = FALSE),
    factor(c(1, 2, NA, NA, NA))
  )

  x <- c(-Inf, 1, Inf)
  r <- chop(x, 1:2, labels = letters[1:3])
  expect_equivalent(r, factor(c("a", "b", "c"), levels = letters[1:3]))

  x <- c(-Inf, 1, Inf)
  # if extend is NULL, we should ensure even Inf is included
  r <- chop(x, -Inf, left = FALSE, labels = c("-Inf", "a"), close_end = FALSE)
  expect_equivalent(r, factor(c("-Inf", "a", "a")))
  r <- chop(x, Inf, labels = c("a", "Inf"), close_end = FALSE)
  expect_equivalent(r, factor(c("a", "a", "Inf")))

  # otherwise, we respect close_end = FALSE
  r <- chop(x, brk_default(c(-Inf, Inf)), labels = "a",
        extend = FALSE, left = FALSE, close_end = FALSE)
  expect_equivalent(r, factor(c(NA, "a", "a")))
  r <- chop(x, c(-Inf, Inf), labels = "a", extend = FALSE, close_end = FALSE)
  expect_equivalent(r, factor(c("a", "a", NA)))

  all_na <- rep(NA_real_, 5)
  expect_silent(chop(all_na, 1:2))
  # not sure if this should be OK or not...
  # expect_silent(chop_quantiles(all_na, c(.25, .75)))
  all_na[1] <- NaN
  expect_silent(chop(all_na, 1:2))
})


test_that("singleton breaks", {
  expect_silent(chop(1:4, 2))
  expect_silent(chop(1:4, 1))
  expect_silent(chop(1:4, 4))
  expect_silent(chop(1:4, 0))
  expect_silent(chop(1:4, 5))
  expect_silent(chop(1, 1))
})


test_that("labels", {
  x <- seq(0.5, 2.5, 0.5)
  expect_equivalent(
          chop(x, 1:2, labels = letters[1:3]),
          factor(c("a", "b", "b", "c", "c"), levels = letters[1:3])
        )
  expect_error(chop(1:10, 3:4, labels = c("a", "a", "a")))
  expect_error(chop(1:10, 3:4, labels = c("a", "b")))
  expect_error(chop(1:10, 3:4, labels = c("a", "b", "c", "d")))

  expect_equivalent(
          chop(x, 1:2, labels = NULL),
          c(1, 2, 2, 3, 3)
        )
})


test_that("break names as labels", {
  expect_equivalent(
    chop(1:4, c(Low = 1, High = 3, 4)),
    factor(c("Low", "Low", "High", "High"))
  )
  expect_equivalent(
    chop(1:5, c(Low = 1, Mid = 3, High = 4)),
    factor(c("Low", "Low", "Mid", "High", "High"))
  )
  expect_equivalent(
    chop(1:4, c(Low = 1, High = 3, 4), labels = letters[1:2]),
    factor(c("a", "a", "b", "b"))
  )
  expect_equivalent(
    chop(1:4, c(Low = 1, High = 3, 4), labels = lbl_endpoints()),
    factor(c("1", "1", "3", "3"))
  )
})


test_that("extend", {
  x <- c(1, 4)
  expect_equivalent(
          chop(x, 2:3, labels = lbl_seq("1"), extend = TRUE),
          factor(c(1, 3))
        )
  expect_equivalent(
          chop(x, 2:3, labels = lbl_seq("1"), extend = FALSE),
          factor(c(NA, NA))
        )
})


test_that("close_end", {
  res <- chop(1:4, 2:3, close_end = TRUE, drop = FALSE)
  expect_equivalent(
    levels(res),
    c("[1, 2)", "[2, 3)", "[3, 4]")
  )

  res <- chop(1:4, 2:3, close_end = FALSE, extend = FALSE, drop = FALSE)
  expect_equivalent(
    levels(res),
    c("[2, 3)")
  )

  res <- chop(1:4, 2:3, close_end = TRUE, extend = FALSE, drop = FALSE)
  expect_equivalent(
    levels(res),
    c("[2, 3]")
  )
})


test_that("raw", {
  x <- 1:10

  expect_silent(
    res <- chop(x, brk_quantiles(c(0.25, 0.75)), raw = TRUE)
  )
  expect_equivalent(
    levels(res),
    c("[1, 3.25)", "[3.25, 7.75)", "[7.75, 10]")
  )

  expect_silent(
    res <- chop(x, brk_quantiles(c(0.25, 0.75)), raw = FALSE)
  )
  expect_equivalent(
    levels(res),
    c("[0%, 25%)", "[25%, 75%)", "[75%, 100%]")
  )

  # raw overrides raw in labels
  withr::local_options(lifecycle_verbosity = "quiet")

  expect_silent(
    res <- chop(x, brk_quantiles(c(0.25, 0.75)),
                  labels = lbl_intervals(raw = FALSE), raw = TRUE)
  )
  expect_equivalent(
    levels(res),
    c("[1, 3.25)", "[3.25, 7.75)", "[7.75, 10]")
  )

  expect_silent(
    res <- chop(x, brk_quantiles(c(0.25, 0.75)),
                  labels = lbl_intervals(raw = TRUE), raw = FALSE)
  )
  expect_equivalent(
    levels(res),
    c("[0%, 25%)", "[25%, 75%)", "[75%, 100%]")
  )
})


test_that("drop", {
  x <- c(1, 3)
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_seq("1"), extend = TRUE,
            drop = TRUE)),
          as.character(c(2, 4))
        )
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_seq("1"), extend = TRUE,
            drop = FALSE)),
          as.character(1:4)
        )
})


test_that("chop_width", {
  x <- 1:10
  expect_equivalent(
    chop_width(x, 2, labels = lbl_seq("1")),
    factor(rep(1:5, each = 2))
  )
  expect_equivalent(
    chop_width(x, 2, 0, labels = lbl_seq("1")),
    factor(c(1, rep(2:4, each = 2), 5, 5, 5))
  )
})


test_that("chop_evenly", {
  x <- 1:10
  expect_equivalent(
    chop_evenly(x, 2, labels = lbl_seq("1")),
    factor(rep(1:2, each = 5))
  )
  expect_error(r <- chop_evenly(x, groups = 2))
})


test_that("chop_proportions", {
  x <- 0:10
  expect_equivalent(
    chop_proportions(x, c(0.2, 0.8), labels = lbl_seq("1")),
    factor(rep(1:3, c(2, 6, 3)))
  )

  expect_equivalent(
    chop_proportions(x, c(0.2, 0.8), labels = lbl_intervals(), raw = FALSE),
    chop_proportions(x, c(0.2, 0.8), labels = lbl_intervals(raw = FALSE),
                       raw = NULL)
  )
})


test_that("chop_quantiles", {
  x <- 1:6
  expect_equivalent(
          chop_quantiles(x, c(.25, .5, .75), labels = lbl_seq("1")),
          as.factor(c(1, 1, 2, 3, 4, 4))
        )

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_equivalent(
    chop_quantiles(x, c(.25, .5, .75), raw = TRUE),
    chop_quantiles(x, c(.25, .5, .75), labels = lbl_intervals(raw = TRUE),
                     raw = NULL)
  )
})


test_that("chop_equally", {
  x <- 1:6
  expect_equivalent(
    chop_equally(x, 2, labels = lbl_seq("1")),
    as.factor(rep(1:2, each = 3))
  )

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_equivalent(
    chop_equally(x, 2, labels = lbl_intervals(raw = FALSE), raw = NULL),
    chop_equally(x, 2, raw = FALSE)
  )

  expect_equivalent(
    chop_equally(x, 2, labels = lbl_intervals(raw = TRUE)),
    chop_equally(x, 2, raw = TRUE)
  )
})


test_that("chop_deciles", {
  x <- rnorm(100)
  expect_identical(
    chop_quantiles(x, 0:10/10),
    chop_deciles(x)
  )
})


test_that("chop_n", {
  expect_silent(res <- chop_n(rnorm(100), 10))
  expect_equivalent(as.vector(table(res)), rep(10, 10))

  # chop_n should give accurate answers even when left = FALSE
  res <- chop_n(1:4, 2, left = FALSE)
  expect_equivalent(as.vector(table(res)), rep(2, 2))

  expect_warning(chop_n(rep(1:3, each = 3), 2))
})


test_that("chop_mean_sd", {
  x <- -1:1 # mean 0, sd 1
  expect_silent(res <- chop_mean_sd(x))
  expect_equivalent(as.vector(table(res)), c(1, 1, 1))
  expect_silent(res2 <- chop_mean_sd(x, sds = 1:2))
  expect_silent(chop_mean_sd(x, sds = c(1, 1.96)))

  lifecycle::expect_deprecated(res3 <- chop_mean_sd(x, sd = 2))
  expect_equivalent(res2, res3)

  withr::local_options(lifecycle_verbosity = "quiet")
  expect_equivalent(
    chop_mean_sd(x, raw = TRUE),
    chop_mean_sd(x, labels = lbl_intervals(raw = TRUE), raw = NULL),
  )
})


test_that("chop_pretty", {
  expect_silent(res <- chop_pretty(1:10))
  expect_silent(res <- chop_pretty(1:10, 3))
  expect_silent(res <- chop_pretty(1:10, 3))
})


test_that("fillet", {
  x <- -2:2
  expect_silent(sole <- fillet(x, -1:1))
  expect_identical(sole, chop(x, -1:1, extend = FALSE, drop = FALSE))
})
