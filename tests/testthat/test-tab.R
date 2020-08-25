test_that("tab", {
  expect_identical(
    tab(1:5, c(2, 4), letters[1:3]),
    table(x = c("a", "b", "b", "c", "c"), useNA = "ifany")
  )
  expect_identical(
    tab(1:5, c(2, 4), letters[1:3]),
    table(x = chop(1:5, c(2, 4), letters[1:3], drop = FALSE), useNA = "ifany")
  )
})


test_that("tab_n", {
  expect_identical(
    tab_n(1:9, 3, lbl_seq()),
    table(x = rep(c("a", "b", "c"), 3), useNA = "ifany")
  )
})


test_that("tab_width", {
  expect_identical(
    tab_width(0:8, 2),
    table(x = c(rep(c("[0, 2)", "[2, 4)", "[4, 6)", "[6, 8)"), 2), "{8}"))
  )
})


test_that("tab_evenly", {
  expect_identical(
    tab_evenly(0:10, 5),
    table(x = c(rep(c("[0, 2)", "[2, 4)", "[4, 6)", "[6, 8)", "[8, 10]"), 2),
      "[8, 10]"))
  )
})


test_that("tab_mean_sd", {
  expect_silent(
          tb <- tab_mean_sd(rnorm(100), sd = 3, extend = TRUE, drop = FALSE)
        )
  expect_equivalent(length(tb), 8)
})
