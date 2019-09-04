
test_that("basic functionality", {
  x <- 1:3
  lbrks <- brk_manual(1:3, rep(TRUE, 3))
  rbrks <- brk_manual(1:3, rep(FALSE, 3))
  rc_brks <- brk_manual(1:3, c(TRUE, TRUE, FALSE))

  expect_equivalent(chop(x, lbrks, lbl_numerals(), extend = FALSE),
        factor(c(1, 2, NA)))
  expect_equivalent(chop(x, rbrks, lbl_numerals(), extend = FALSE),
        factor(c(NA, 1, 2)))
  expect_equivalent(chop(x, rc_brks, lbl_numerals(), extend = FALSE),
        factor(c(1, 2, 2)))


})


test_that("NA, NaN and Inf", {
  y <- c(1:3, NA, NaN)
  expect_equivalent(chop(y, 1:3, lbl_numerals(), extend = FALSE),
        factor(c(1, 2, 2, NA, NA)))

  x <- c(-Inf, 1, Inf)
  r <- chop(x, 1:2, labels = letters[1:3])
  expect_equivalent(r, factor(c("a", "b", "c"), levels = letters[1:3]))

  x <- c(-Inf, 1, Inf)
  r <- chop(x, brk_right(-Inf, close_end = FALSE), labels = "a")
  expect_equivalent(r, factor(c(NA, "a", "a"), levels = "a"))
  r <- chop(x, brk_left(Inf, close_end = FALSE), labels = "a")
  expect_equivalent(r, factor(c("a", "a", NA), levels = "a"))

  all_na <- rep(NA, 5)
  expect_silent(chop(all_na, 1:2))
  # not sure if this should be OK or not...
  # expect_silent(chop_quantiles(all_na, c(.25, .75)))
  all_na[1] <- NaN
  expect_silent(chop(all_na, 1:2))
})


test_that("labels", {
  x <- seq(0.5, 2.5, 0.5)
  expect_equivalent(
          chop(x, 1:2, labels = letters[1:3]),
          factor(c("a", "b", "b", "b", "c"), levels = letters[1:3])
        )
  expect_error(chop(1:10, 3:4, labels = c("a", "a", "a")))
  expect_error(chop(1:10, 3:4, labels = c("a", "b")))
  expect_error(chop(1:10, 3:4, labels = c("a", "b", "c", "d")))
})


test_that("extend", {
  x <- c(1, 4)
  expect_equivalent(
          chop(x, 2:3, labels = lbl_numerals(), extend = TRUE),
          factor(c(1, 3))
        )
  expect_equivalent(
          chop(x, 2:3, labels = lbl_numerals(), extend = FALSE),
          factor(c(NA, NA))
        )
})


test_that("drop", {
  x <- c(1, 3)
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_numerals(), extend = TRUE,
            drop = TRUE)),
          as.character(2:3)
        )
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_numerals(), extend = TRUE,
            drop = FALSE)),
          as.character(1:4)
        )
})


test_that("chop_width", {
  x <- 1:10
  expect_equivalent(
    chop_width(x, 2, labels = lbl_numerals()),
    factor(rep(1:5, each = 2))
  )
  expect_equivalent(
    chop_width(x, 2, 0, labels = lbl_numerals()),
    factor(c(1, rep(2:4, each = 2), 5, 5, 5))
  )
})


test_that("chop_quantiles", {
  x <- 1:6
  expect_equivalent(
          chop_quantiles(x, c(.25, .5, .75)),
          as.factor(c("[0%, 25%)", "[0%, 25%)", "[25%, 50%)", "[50%, 75%)",
            "[75%, 100%]", "[75%, 100%]"))
        )
})


test_that("chop_equally", {
  x <- 1:6
  expect_equivalent(
    chop_equally(x, 2),
    as.factor(rep(c("[0%, 50%)", "[50%, 100%]"), each = 3))
  )
})


test_that("chop_deciles", {
  x <- rnorm(100)
  expect_identical(
    chop_quantiles(x, 1:9/10),
    chop_deciles(x)
  )
})


test_that("chop_n", {
  expect_silent(res <- chop_n(rnorm(100), 10))
  expect_equivalent(as.vector(table(res)), rep(10, 10))
})


test_that("chop_mean_sd", {
  x <- -1:1 # mean 0, sd 1
  expect_silent(chop_mean_sd(x))
  expect_silent(chop_mean_sd(x, sd = 2))
  expect_error(chop_mean_sd(x, sd = 1.5), "integer")
})
