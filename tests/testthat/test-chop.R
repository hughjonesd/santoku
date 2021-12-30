
test_that("basic functionality", {
  x <- 1:3
  lbrks <- brk_manual(1:3, rep(TRUE, 3))
  rbrks <- brk_manual(1:3, rep(FALSE, 3))
  rc_brks <- brk_manual(1:3, c(TRUE, TRUE, FALSE))

  expect_equivalent(chop(x, lbrks, lbl_seq("1"), extend = FALSE),
        factor(c(1, 2, NA)))
  expect_equivalent(chop(x, rbrks, lbl_seq("1"), extend = FALSE),
        factor(c(NA, 1, 2)))
  expect_equivalent(chop(x, rc_brks, lbl_seq("1"), extend = FALSE),
        factor(c(1, 2, 2)))


})


test_that("NA, NaN and Inf", {
  y <- c(1:3, NA, NaN)
  expect_equivalent(chop(y, 1:3, lbl_seq("1"), extend = FALSE),
        factor(c(1, 2, NA, NA, NA)))

  x <- c(-Inf, 1, Inf)
  r <- chop(x, 1:2, labels = letters[1:3])
  expect_equivalent(r, factor(c("a", "b", "c"), levels = letters[1:3]))

  x <- c(-Inf, 1, Inf)
  # if extend is NULL, we should ensure even Inf is included
  r <- chop(x, -Inf, left = FALSE, labels = c("-Inf", "a"))
  expect_equivalent(r, factor(c("-Inf", "a", "a"), levels = c("-Inf", "a")))
  r <- chop(x, Inf, labels = c("a", "Inf"))
  expect_equivalent(r, factor(c("a", "a", "Inf"), levels = c("a", "Inf")))

  # otherwise, we respect close_end = FALSE
  r <- chop(x, brk_right(c(-Inf, Inf)), labels = "a",
        extend = FALSE)
  expect_equivalent(r, factor(c(NA, "a", "a"), levels = "a"))
  r <- chop(x, c(-Inf, Inf), labels = "a", extend = FALSE)
  expect_equivalent(r, factor(c("a", "a", NA), levels = "a"))

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
    factor(c(1, rep(2:4, each = 2), 5, 5, 6))
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


test_that("chop_quantiles", {
  x <- 1:6
  expect_equivalent(
          chop_quantiles(x, c(.25, .5, .75), labels = lbl_seq("1")),
          as.factor(c(1, 1, 2, 3, 4, 4))
        )
})


test_that("chop_equally", {
  x <- 1:6
  expect_equivalent(
    chop_equally(x, 2, labels = lbl_seq("1")),
    as.factor(rep(1:2, each = 3))
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

  expect_warning(chop_n(rep(1:3, each = 3), 2))
})


test_that("chop_mean_sd", {
  x <- -1:1 # mean 0, sd 1
  expect_silent(chop_mean_sd(x))
  expect_silent(chop_mean_sd(x, sd = 2))
  expect_silent(chop_mean_sd(x, sd = 1.96))
})


test_that("fillet", {
  x <- -2:2
  expect_silent(sole <- fillet(x, -1:1))
  expect_identical(sole, chop(x, -1:1, extend = FALSE, drop = FALSE))
})
