
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

  x <- seq(0.5, 2.5, 0.5)
  r <- chop(x, 1:2, labels = letters[1:3])
  expect_equivalent(r, factor(c("a", "b", "b", "b", "c"), levels = letters[1:3]))

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
          levels(chop(x, 1:3, labels = lbl_numerals(), drop = TRUE)),
          as.character(2:3)
        )
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_numerals(), drop = FALSE)),
          as.character(1:4)
        )
})


test_that("chop_quantiles", {
  x <- 1:6
  expect_equivalent(
          chop_quantiles(x, c(.25, .5, .75)),
          as.factor(c("0-25%", "0-25%", "25-50%", "50-75%", "75-100%", "75-100%"))
        )
})
