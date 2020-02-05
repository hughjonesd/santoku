
test_that("lbl_manual", {
  brk <- brk_manual(1:3, rep(TRUE, 3))(1, FALSE)

  expect_error(lbl_manual(c("a", "a")))
  expect_equivalent(lbl_manual(letters[1])(brk), c("a", "aa"))
})


test_that("lbl_seq", {
  brk <- brk_manual(1:3, rep(TRUE, 3))(1, FALSE)

  expect_error(lbl_seq("b"))
  expect_error(lbl_seq("a1"))
  expect_error(lbl_seq(c("a", "b")))

  expect_equivalent(lbl_seq()(brk), c("a", "b"))
  expect_equivalent(lbl_seq("A")(brk), c("A", "B"))
  expect_equivalent(lbl_seq("i")(brk), c("i", "ii"))
  expect_equivalent(lbl_seq("I")(brk), c("I", "II"))
  expect_equivalent(lbl_seq("1")(brk), c("1", "2"))

  expect_equivalent(lbl_seq("(a)")(brk), c("(a)", "(b)"))
  expect_equivalent(lbl_seq("i.")(brk), c("i.", "ii."))
  expect_equivalent(lbl_seq("I:")(brk), c("I:", "II:"))
  expect_equivalent(lbl_seq("1)")(brk), c("1)", "2)"))

  brk_many <- brk_manual(1:28, rep(TRUE, 28))(1, FALSE)
  expect_equivalent(lbl_seq("a")(brk_many), c(letters, "aa"))
  expect_equivalent(lbl_seq("A)")(brk_many), paste0(c(LETTERS, "AA"), ")"))
})


test_that("lbl_dash", {
  brk <- brk_manual(1:3, rep(TRUE, 3))(1, FALSE)
  expect_equivalent(lbl_dash()(brk), c("1 - 2", "2 - 3"))
})


test_that("lbl_format", {
  brk <- brk_manual(1:3, rep(TRUE, 3))(1, FALSE)
  expect_equivalent(lbl_format("<%s to %s>")(brk), c("<1 to 2>", "<2 to 3>"))
  brk <- brk_left(c(1, 2, 2, 3))(1, FALSE)
  expect_equivalent(lbl_format("<%s to %s>", "|%s|")(brk),
        c("<1 to 2>", "|2|", "<2 to 3>"))
  expect_equivalent(lbl_format("%.2f to %.2f", fmt1 = "%.2f", raw = TRUE)(brk),
        c("1.00 to 2.00", "2.00", "2.00 to 3.00"))
})


test_that("lbl_intervals", {
  lbrk <- brk_manual(1:3, rep(TRUE, 3))(1, FALSE)
  rbrk <- brk_manual(1:3, rep(FALSE, 3))(1, FALSE)
  expect_equivalent(lbl_intervals()(lbrk), c("[1, 2)", "[2, 3)"))
  expect_equivalent(lbl_intervals()(rbrk), c("(1, 2]", "(2, 3]"))

  lbrk <- brk_left(1:3)(1, FALSE)
  expect_equivalent(lbl_intervals()(lbrk), c("[1, 2)", "[2, 3]"))
  rbrk <- brk_right(1:3)(1, FALSE)
  expect_equivalent(lbl_intervals()(rbrk), c("[1, 2]", "(2, 3]"))

  sbrk <- brk_left(c(1, 2, 2, 3))(1, FALSE)
  expect_equivalent(lbl_intervals()(sbrk), c("[1, 2)", "{2}", "(2, 3]"))

  mbrk <- brk_manual(1:4, c(FALSE, TRUE, FALSE, TRUE))(1, FALSE)
  expect_equivalent(lbl_intervals()(mbrk), c("(1, 2)", "[2, 3]", "(3, 4)"))
})


test_that("breaks labels don't produce duplicates", {
  brk <- brk_left(c(1.333335, 1.333336, 1.333337, 5))(1, FALSE)
  lbls <- lbl_intervals()(brk)
  expect_true(anyDuplicated(lbls) == 0)

  brk <- brk_left(c(1.333333335, 1.333333336, 1.333333337, 5))(1, FALSE)
  lbls <- lbl_intervals()(brk)
  expect_true(anyDuplicated(lbls) == 0)
})




