test_that("tab", {
  expect_identical(
    tab(1:5, c(2, 4), letters[1:3]),
    table(x = c("a", "b", "b", "c", "c"), useNA = "ifany", dnn = NULL)
  )
  expect_identical(
    tab(1:5, c(2, 4), letters[1:3]),
    table(x = chop(1:5, c(2, 4), letters[1:3], drop = FALSE), useNA = "ifany",
            dnn = NULL)
  )
})


test_that("tab_n", {
  expect_identical(
    tab_n(1:9, 3, lbl_seq()),
    table(x = rep(c("a", "b", "c"), 3), useNA = "ifany", dnn = NULL)
  )
})


test_that("tab_width", {
  expect_identical(
    tab_width(0:7, 2),
    table(x = c(rep(c("[0, 2)", "[2, 4)", "[4, 6)", "[6, 8]"), 2)),
            dnn = NULL)
  )
})


test_that("tab_evenly", {
  expect_identical(
    tab_evenly(0:10, 5),
    table(x = c(rep(c("[0, 2)", "[2, 4)", "[4, 6)", "[6, 8)", "[8, 10]"), 2),
      "[8, 10]"), dnn = NULL)
  )
})


test_that("tab_proportions", {
  expect_identical(
    tab_proportions(0:10, c(0.2, 0.8)),
    table(rep(c("[0, 2)", "[2, 8)", "[8, 10]"), c(2, 6, 3)), dnn = NULL)
  )
})


test_that("tab_mean_sd", {
  expect_silent(
    tb <- tab_mean_sd(rnorm(100), sds = 1:3, extend = TRUE, drop = FALSE)
  )
  expect_equivalent(length(tb), 8)
})


test_that("tab_pretty", {
  expect_silent(
    tb <- tab_pretty(1:9)
  )
  expect_equivalent(length(tb), 5)
})


test_that("tab_quantiles", {
  expect_identical(
    tab_quantiles(1:4, c(0, .25, .5, .75, 1)),
    table(x = c("[0%, 25%)", "[25%, 50%)", "[50%, 75%)", "[75%, 100%]"),
          dnn = NULL)
  )
})

test_that("tab_deciles", {
  expect_identical(
    tab_deciles(0:9),
    table(x = c("[0%, 10%)", "[10%, 20%)", "[20%, 30%)", "[30%, 40%)",
                "[40%, 50%)", "[50%, 60%)", "[60%, 70%)", "[70%, 80%)",
                "[80%, 90%)", "[90%, 100%]"),
          dnn = NULL)
  )
})

test_that("tab_equally", {
  expect_identical(
    tab_equally(1:4, 4),
    table(x = c("[1, 1.75)", "[1.75, 2.5)", "[2.5, 3.25)", "[3.25, 4]"),
          dnn = NULL)
  )
})
