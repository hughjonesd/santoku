
test_that("sequential labels", {
  brk <- brk_manual(1:3, rep(TRUE, 3))
  expect_equivalent(lbl_numerals()(brk), as.character(1:2))
  expect_equivalent(lbl_roman()(brk), tolower(as.roman(1:2)))
  expect_equivalent(lbl_ROMAN()(brk), as.character(as.roman(1:2)))
  expect_equivalent(lbl_letters()(brk), letters[1:2])
  expect_equivalent(lbl_LETTERS()(brk), LETTERS[1:2])

  expect_equivalent(lbl_numerals("(%s)")(brk), sprintf("(%s)", 1:2))
})


test_that("lbl_dash", {
  brk <- brk_manual(1:3, rep(TRUE, 3))
  expect_equivalent(lbl_dash()(brk), c("1 - 2", "2 - 3"))
})


test_that("lbl_format", {
  brk <- brk_manual(1:3, rep(TRUE, 3))
  expect_equivalent(lbl_format("<%d to %d>")(brk), c("<1 to 2>", "<2 to 3>"))
  brk <- brk_left(c(1, 2, 2, 3))
  expect_equivalent(lbl_format("<%d to %d>", "|%d|")(brk),
        c("<1 to 2>", "|2|", "<2 to 3>"))
})


test_that("lbl_quantiles", {
  expect_equivalent(
          lbl_quantiles(0.5)(1:2, TRUE),
          c("0-50%", "50-100%")
        )
  expect_equivalent(
          lbl_quantiles(c(0.25, 0.75))(1:2, FALSE),
          "25-75%"
        )
})


test_that("lbl_intervals", {
  lbrk <- brk_manual(1:3, rep(TRUE, 3))
  rbrk <- brk_manual(1:3, rep(FALSE, 3))
  expect_equivalent(lbl_intervals()(lbrk), c("[1, 2)", "[2, 3)"))
  expect_equivalent(lbl_intervals()(rbrk), c("(1, 2]", "(2, 3]"))

  lbrk <- brk_left(1:3)
  expect_equivalent(lbl_intervals()(lbrk), c("[1, 2)", "[2, 3]"))
  rbrk <- brk_right(1:3)
  expect_equivalent(lbl_intervals()(rbrk), c("[1, 2]", "(2, 3]"))

  sbrk <- brk_left(c(1, 2, 2, 3))
  expect_equivalent(lbl_intervals()(sbrk), c("[1, 2)", "{2}", "(2, 3]"))

  mbrk <- brk_manual(1:4, c(FALSE, TRUE, FALSE, TRUE))
  expect_equivalent(lbl_intervals()(mbrk), c("(1, 2)", "[2, 3]", "(3, 4)"))
})


test_that("breaks labels don't produce duplicates", {
  lbls <- lbl_intervals()(brk_left(c(1.333335, 1.333336, 1.333337, 5)), FALSE)
  expect_true(anyDuplicated(lbls) == 0)
})




