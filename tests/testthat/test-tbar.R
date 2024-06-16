
local_edition(3)

test_that("tbar works", {
  x <- c("a", "b", "c", "c", "c")
  expect_snapshot(tbar(x))
  expect_snapshot(tbar(table(x)))
  expect_snapshot(tbar(proportions(table(x))))
  expect_snapshot(tbar(proportions(table(x)), width = 15))
  expect_snapshot(tbar(x, useNA = "always"))
})
