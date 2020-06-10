
brackets <- function (x) paste0("(", x, ")")


test_that("lbl_manual", {
  brk <- brk_res(brk_manual(1:3, rep(TRUE, 3)))

  expect_error(lbl_manual(c("a", "a")))
  expect_equivalent(lbl_manual(letters[1])(brk), c("a", "aa"))
})


test_that("lbl_seq", {
  brk <- brk_res(brk_manual(1:3, rep(TRUE, 3)))

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

  brk_many <- brk_res(brk_manual(1:28, rep(TRUE, 28)))
  expect_equivalent(lbl_seq("a")(brk_many), c(letters, "aa"))
  expect_equivalent(lbl_seq("A)")(brk_many), paste0(c(LETTERS, "AA"), ")"))
})


test_that("lbl_dash", {
  brk <- brk_res(brk_manual(1:3, rep(TRUE, 3)))
  expect_equivalent(lbl_dash()(brk), c("1 - 2", "2 - 3"))
  expect_equivalent(lbl_dash("/")(brk), c("1/2", "2/3"))
})


test_that("lbl_dash arguments", {
  brk <- brk_res(brk_default(1:3), 1:2)
  expect_equivalent(lbl_dash(fmt = "%.2f")(brk), c("1.00 - 2.00", "2.00 - 3.00"))

  qbrk <- brk_res(brk_quantiles(c(0, .5, 1)), x = 0:10)
  expect_equivalent(lbl_dash()(qbrk), c("0% - 50%", "50% - 100%"))
  expect_equivalent(lbl_dash(raw = TRUE)(qbrk), c("0 - 5", "5 - 10"))
  expect_equivalent(
    lbl_dash(raw = TRUE, fmt = "%.2f")(qbrk),
    c("0.00 - 5.00", "5.00 - 10.00")
  )
  expect_equivalent(
    lbl_dash(fmt = "%.3f")(qbrk),
    c("0.000 - 0.500", "0.500 - 1.000")
  )

  expect_equivalent(lbl_dash(fmt = brackets)(brk), c("(1) - (2)", "(2) - (3)"))
})


test_that("lbl_format", {
  brk <- brk_res(brk_manual(1:3, rep(TRUE, 3)))
  expect_equivalent(
    lbl_format("<%.1f to %.1f>")(brk),
    c("<1.0 to 2.0>", "<2.0 to 3.0>")
  )

  bracket2 <- function (x, y) paste0("(", x, " - ", y, ")")
  expect_equivalent(
    lbl_format(fmt = bracket2)(brk),
    c("(1 - 2)", "(2 - 3)")
  )

  brk2 <- brk_res(brk_left(c(1, 2, 2, 3)))
  expect_equivalent(
    lbl_format("<%.1f to %.1f>", "|%.3f|")(brk2),
    c("<1.0 to 2.0>", "|2.000|", "<2.0 to 3.0>")
  )
  expect_equivalent(
    lbl_format(bracket2, "%s")(brk2),
    c("(1 - 2)", "2", "(2 - 3)")
  )
})


test_that("lbl_format arguments", {
  qbrk <- brk_res(brk_quantiles(c(0, .5, 1)), x = 0:10)
  expect_equivalent(
    lbl_format("%s / %s", raw = TRUE)(qbrk),
    c("0 / 5", "5 / 10")
  )
})


test_that("lbl_intervals", {
  lbrk <- brk_res(brk_manual(1:3, rep(TRUE, 3)))
  rbrk <- brk_res(brk_manual(1:3, rep(FALSE, 3)))
  expect_equivalent(lbl_intervals()(lbrk), c("[1, 2)", "[2, 3)"))
  expect_equivalent(lbl_intervals()(rbrk), c("(1, 2]", "(2, 3]"))

  lbrk <- brk_res(brk_left(1:3), close_end = TRUE)
  expect_equivalent(lbl_intervals()(lbrk), c("[1, 2)", "[2, 3]"))
  rbrk <- brk_res(brk_right(1:3), close_end = TRUE)
  expect_equivalent(lbl_intervals()(rbrk), c("[1, 2]", "(2, 3]"))

  sbrk <- brk_res(brk_left(c(1, 2, 2, 3)))
  expect_equivalent(lbl_intervals()(sbrk), c("[1, 2)", "{2}", "(2, 3)"))

  mbrk <- brk_res(brk_manual(1:4, c(FALSE, TRUE, FALSE, TRUE)))
  expect_equivalent(lbl_intervals()(mbrk), c("(1, 2)", "[2, 3]", "(3, 4)"))
})

test_that("lbl_intervals arguments", {
  lbrk <- brk_res(brk_left(c(1, 2, 2, 3) + 0.5))
  expect_equivalent(
    lbl_intervals(fmt = "%.2f")(lbrk),
    c("[1.50, 2.50)", "{2.50}",  "(2.50, 3.50)")
  )

  lbrk <- brk_res(brk_left(1:3 * 10000))
  expect_equivalent(
    lbl_intervals(fmt = "%2g")(lbrk),
    c("[10000, 20000)", "[20000, 30000)")
  )

  qbrk <- brk_res(brk_quantiles(c(0, 0.5, 1)), x = 0:10)
  expect_equivalent(
    lbl_intervals()(qbrk),
    c("[0%, 50%)", "[50%, 100%)")
  )
  expect_equivalent(
    lbl_intervals(raw = TRUE)(qbrk),
    c("[0, 5)", "[5, 10)")
  )
  expect_equivalent(
    lbl_intervals(raw = TRUE, fmt = "%.2f")(qbrk),
    c("[0.00, 5.00)", "[5.00, 10.00)")
  )
  expect_equivalent(
    lbl_intervals(fmt = "%.2f")(qbrk),
    c("[0.00, 0.50)", "[0.50, 1.00)")
  )
  expect_equivalent(
    lbl_intervals(fmt = percent)(qbrk),
    c("[0%, 50%)", "[50%, 100%)")
  )
})


test_that("lbl_discrete", {
  lbrk <- brk_res(brk_manual(1:3, rep(TRUE, 3)))
  rbrk <- brk_res(brk_manual(1:3, rep(FALSE, 3)))

  expect_equivalent(lbl_discrete()(lbrk), c("1", "2"))
  expect_equivalent(lbl_discrete()(rbrk), c("2", "3"))

  lbrk2 <- brk_res(brk_manual(c(1, 3, 5), rep(TRUE, 3)))
  expect_equivalent(lbl_discrete()(lbrk2), c("1 - 2", "3 - 4"))
  expect_equivalent(lbl_discrete(" to ")(lbrk2), c("1 to 2", "3 to 4"))

  lbrk3 <- brk_res(brk_left(c(1, 3, 3, 5)), close_end = TRUE)
  expect_equivalent(lbl_discrete()(lbrk3), c("1 - 2", "3", "4 - 5"))

  # break containing (1,2) which has no integer in it:
  open_brk <- brk_res(brk_manual(1:3, c(FALSE, TRUE, FALSE)))
  expect_warning(l <- lbl_discrete()(open_brk))
  expect_equivalent(l[1], "--")
})


test_that("lbl_discrete arguments", {
  lbrk <- brk_res(brk_default(c(1, 3, 5)))
  expect_equivalent(
    lbl_discrete(fmt = "(%s)")(lbrk),
    c("(1) - (2)", "(3) - (4)")
  )

  expect_equivalent(
    lbl_discrete(fmt = brackets)(lbrk),
    c("(1) - (2)", "(3) - (4)")
  )
})


test_that("lbl_endpoint", {
  lbrk <- brk_res(brk_default(c(1, 3, 5)), extend = FALSE)
  expect_equivalent(
    lbl_endpoint()(lbrk),
    c("1", "3")
  )
  expect_equivalent(
    lbl_endpoint(left = FALSE)(lbrk),
    c("3", "5")
  )
})


test_that("lbl_endpoint arguments", {
  lbrk <- brk_res(brk_default(c(1, 3, 5)), extend = FALSE)
  expect_equivalent(
    lbl_endpoint(fmt = "%.2f")(lbrk),
    c("1.00", "3.00")
  )
  expect_equivalent(
    lbl_endpoint(fmt = percent)(lbrk),
    c("100%", "300%")
  )
})


test_that("bug: breaks labels don't produce duplicates", {
  brk <- brk_res(brk_left(c(1.333333335, 1.333333336, 1.333333337, 5)))
  lbls <- lbl_intervals()(brk)
  expect_equivalent(anyDuplicated(lbls), 0)
  lbls <- lbl_dash()(brk)
  expect_equivalent(anyDuplicated(lbls), 0)

  brk <- brk_res(brk_quantiles(seq(0, 1, 0.0001)), x = rnorm(10000))
  lbls <- lbl_intervals()(brk)
  expect_equivalent(anyDuplicated(lbls), 0)
  lbls <- lbl_dash()(brk)
  expect_equivalent(anyDuplicated(lbls), 0)
})
