test_that("tab", {
  expect_identical(
    tab(1:5, c(2, 4), letters[1:3]),
    table(x = c("a", "b", "b", "b", "c"), useNA = "ifany")
  )
  expect_identical(
    tab(1:5, c(2, 4), letters[1:3]),
    table(x = chop(1:5, c(2, 4), letters[1:3], drop = FALSE), useNA = "ifany")
  )
})


test_that("tab_size", {
  skip("Not working yet")
  expect_identical(
    tab_size(1:9, 3, lbl_letters(), drop = TRUE),
    table(x = rep(c("a", "b", "c"), 3), useNA = "ifany")
  )
})


test_that("tab_width", {
  expect_identical(
    tab_width(0:10, 2, drop = TRUE),
    table(x = c(rep(c("[0, 2)", "[2, 4)", "[4, 6)", "[6, 8)", "[8, 10]"), 2),
          "[8, 10]"))
  )
  skip("Not working yet")
  expect_identical(
    tab_width(0:10, 2),
    table(x = c(rep(c("[0, 2)", "[2, 4)", "[4, 6)", "[6, 8)", "[8, 10]"), 2),
      "[8, 10]"))
  )
})

