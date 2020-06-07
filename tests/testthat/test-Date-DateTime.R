
d1 <- seq(as.Date("1975-10-27"), as.Date("1975-11-27"), by = "day")

db1 <- as.Date(c("1975-11-01", "1975-11-15"))

dt1 <- seq(as.POSIXct("2000-01-01 15:00"), length = 20, by = "1 min")

dtb1 <- dt1[c(5, 15)]

test_that("Basic chop", {
  expect_silent(chop(d1, db1))
  expect_silent(chop(dt1, dtb1))
  lb <- lbl_seq()
  expect_equivalent(chop(d1, db1, lb), chop(as.POSIXct(d1), db1, lb))
  expect_equivalent(chop(d1, db1, lb), chop(d1, as.POSIXct(db1), lb))
})


test_that("Basic breaks", {
  expect_silent(brk_res(brk_default(db1), d1, extend = FALSE))
  expect_silent(brk_res(brk_default(db1), d1, extend = NULL))
  expect_silent(brk_res(brk_default(db1), d1, extend = TRUE))
})


test_that("chop_equally", {
  expect_silent(chop_equally(d1, groups = 3))
  expect_silent(chop_equally(dt1, groups = 3))
})


test_that("chop_n", {
  expect_silent(chop_n(d1, 5))
  expect_silent(chop_n(dt1, 5))
})


test_that("chop_quantiles", {
  expect_silent(chop_quantiles(d1, c(.1, .5, .9)))
  expect_silent(chop_quantiles(dt1, c(.1, .5, .9)))
})


test_that("chop_mean_sd", {
  expect_silent(chop_mean_sd(d1))
  expect_silent(chop_mean_sd(dt1))
})


test_that("chop_width: difftime", {
  difftime_w1 <- as.difftime(5, units = "days")
  difftime_w2 <- as.difftime(5, units = "mins")

  expect_silent(chop_width(d1, width = difftime_w1))
  expect_silent(chop_width(dt1, width = difftime_w2))

  expect_silent(
    chop_width(d1, width = difftime_w1, start = as.Date("1975-11-01"))
  )
  expect_silent(
    chop_width(dt1, width = difftime_w2, start = as.POSIXct("2000-01-01 15:05"))
  )
})


test_that("chop_width: Duration", {
  skip_if_not_installed("lubridate")
  library(lubridate)

  duration_w1 <- ddays(5)
  duration_w2 <- dminutes(5)

  expect_silent(chop_width(d1, width = duration_w1))
  expect_silent(chop_width(dt1, width = duration_w2))
})


test_that("chop_width: Period", {
  skip_if_not_installed("lubridate")
  library(lubridate)

  period_w1 <- days(5)
  period_w2 <- minutes(5)
  expect_silent(chop_width(d1, width = period_w1))
  expect_silent(chop_width(dt1, width = period_w2))

  # TODO: include tests that Period deals with quirks
})


test_that("Date labels", {
  li <- lbl_intervals()
  b <- brk_res(brk_default(db1))
  expect_equivalent(
    li(b), "[1975-11-01, 1975-11-15)"
  )

  b2 <- brk_res(brk_default(db1), x = as.Date("1975-01-01"), extend = TRUE)
  expect_equivalent(
    li(b2), c("[-Inf, 1975-11-01)", "[1975-11-01, 1975-11-15)", "[1975-11-15, Inf]")
  )

  expect_equivalent(
    lbl_intervals(fmt = "%y %m %d")(b),
    "[75 11 01, 75 11 15)"
  )

  expect_equivalent(
    lbl_dash(" to ")(b),
    "1975-11-01 to 1975-11-15"
  )

  expect_equivalent(
    lbl_dash(" to ", fmt = "%d/%m")(b),
    "01/11 to 15/11"
  )

})
