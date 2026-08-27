
d1 <- seq(as.Date("1975-10-27"), as.Date("1975-11-27"), by = "day")

db1 <- as.Date(c("1975-11-01", "1975-11-15"))

dt1 <- seq(as.POSIXct("2000-01-01 15:00"), length = 20, by = "1 min")

dtb1 <- dt1[c(5, 15)]

table_vals <- function (x) unclass(table(x))


test_that("Basic chop", {
  expect_silent(chop(d1, db1))
  expect_silent(chop(dt1, dtb1))
})


test_that("Chop with conversion", {
  lb <- lbl_seq()
  withr::with_timezone("UTC", {
    expect_equal(chop(d1, db1, lb), chop(as.POSIXct(d1), db1, lb), ignore_attr = TRUE)
    expect_equal(chop(d1, db1, lb), chop(d1, as.POSIXct(db1), lb), ignore_attr = TRUE)
  })
})


test_that("Basic breaks", {
  expect_silent(brk_res(brk_default(db1), d1, extend = FALSE))
  expect_silent(brk_res(brk_default(db1), d1, extend = NULL))
  expect_silent(brk_res(brk_default(db1), d1, extend = TRUE))

  expect_silent(brk_res(brk_default(db1), d1, left = FALSE))
  expect_silent(brk_res(brk_default(db1), d1, close_end = TRUE))
  expect_silent(brk_res(brk_default(db1), d1, left = FALSE, close_end = TRUE))
})


test_that("chop_equally", {
  expect_silent(res <- chop_equally(d1, groups = 4))
  expect_equal(table_vals(res), rep(8, 4), ignore_attr = TRUE)

  expect_silent(res2 <- chop_equally(dt1, groups = 4))
  expect_equal(table_vals(res2), rep(5, 4), ignore_attr = TRUE)
})


test_that("chop_n", {
  expect_silent(res <- chop_n(d1, 4))
  expect_equal(table_vals(res), rep(4, 8), ignore_attr = TRUE)

  expect_silent(res2 <- chop_n(dt1, 5))
  expect_equal(table_vals(res2), rep(5, 4), ignore_attr = TRUE)
})


test_that("chop_quantiles", {
  # `left = FALSE` works better with type 1 quantiles, which round down.
  expect_silent(res1 <- chop_quantiles(d1, 0:4/4, left = FALSE))
  expect_equal(table_vals(res1), rep(8, 4), ignore_attr = TRUE)

  expect_silent(res2 <- chop_quantiles(dt1, 0:5/5, left = FALSE))
  expect_equal(table_vals(res2), rep(4, 5), ignore_attr = TRUE)
})


test_that("chop_mean_sd", {
  expect_silent(res <- chop_mean_sd(d1))
  cmp <- cut(d1, mean(d1) + (-2:2) * sd(d1), right = FALSE)
  expect_equal(table_vals(res), table_vals(cmp), ignore_attr = TRUE)

  expect_silent(res2 <- chop_mean_sd(dt1))
  cmp2 <- cut(dt1, mean(dt1) + (-2:2) * sd(dt1), right = FALSE)
  expect_equal(table_vals(res2), table_vals(cmp2), ignore_attr = TRUE)

  expect_silent(res3 <- chop_mean_sd(d1, c(1, 1.4)))
  # the -10 and 10 capture values outside 1.4 sds:
  cmp3 <- cut(d1,  mean(d1) + c(-10, -1.4, -1, 0, 1, 1.4, 10) * sd(d1), right = FALSE)
  expect_equal(table_vals(res3), table_vals(cmp3), ignore_attr = TRUE)

  weights <- seq_along(d1)
  expect_silent(res4 <- chop_mean_sd(d1, weights = weights))
  weighted_sd <- sqrt(Hmisc::wtd.var(
    as.numeric(d1),
    weights = weights,
    normwt = TRUE
  ))
  cmp4 <- cut(
    d1,
    weighted.mean(d1, weights) + c(-10, -2:2) * weighted_sd,
    right = FALSE
  )
  expect_equal(table_vals(res4), table_vals(cmp4), ignore_attr = TRUE)
})


test_that("chop_pretty", {
  expect_silent(res <- chop_pretty(d1))
  cmp <- chop(d1, base::pretty(d1))
  expect_equal(
    table_vals(res),
    table_vals(cmp),
    ignore_attr = TRUE
  )
})


test_that("chop_width: difftime", {
  difftime_w1 <- as.difftime(4, units = "days")

  expect_silent(res1 <- chop_width(d1, width = difftime_w1))
  expect_equal(table_vals(res1), rep(4, 8), ignore_attr = TRUE)

  expect_silent(
    res2 <- chop_width(d1, width = difftime_w1, start = as.Date("1975-11-01"))
  )
  tv <- table_vals(res2)
  expect_true(all(tv[c(-1, -length(tv))] == 4))

  difftime_w2 <- as.difftime(5, units = "mins")

  expect_silent(res3 <- chop_width(dt1, width = difftime_w2))
  expect_equal(table_vals(res3), rep(5, 4), ignore_attr = TRUE)

  expect_silent(
    res4 <- chop_width(dt1, width = difftime_w2,
          start = as.POSIXct("2000-01-01 15:10"))
  )
  expect_equal(table_vals(res4), c(10, 5, 5), ignore_attr = TRUE)

  expect_silent(
    res5 <- chop_width(d1, width = as.difftime(-4, units = "days"))
  )
  expect_equal(table_vals(res5), rep(4, 8), ignore_attr = TRUE)

  expect_silent(
    res6 <- chop_width(d1, width = as.difftime(-4, units = "days"),
          start = as.Date("1975-11-25"))
  )
  tv <- table_vals(res6)
  expect_true(all(tv[c(-1, -length(tv))] == 4))

  expect_silent(
    res7 <- chop_width(dt1, width = as.difftime(-5, units = "mins"))
  )
  expect_equal(table_vals(res7), rep(5, 4), ignore_attr = TRUE)

  expect_silent(chop_width(d1, as.difftime(7, units = "days")))
  expect_silent(chop_width(dt1, as.difftime(7, units = "mins")))
})


test_that("chop_width: Duration", {
  skip_if_not_installed("lubridate")
  library(lubridate)

  duration_w1 <- ddays(4)

  expect_silent(res1 <- chop_width(d1, width = duration_w1))
  expect_equal(table_vals(res1), rep(4, 8), ignore_attr = TRUE)

  expect_silent(
    res2 <- chop_width(d1, width = duration_w1, start = as.Date("1975-11-16"))
  )
  expect_equal(table_vals(res2), c(20, 4, 4, 4), ignore_attr = TRUE)

  duration_w2 <- dminutes(5)

  expect_silent(res3 <- chop_width(dt1, width = duration_w2))
  expect_equal(table_vals(res3), rep(5, 4), ignore_attr = TRUE)

  expect_silent(
    res4 <- chop_width(dt1, duration_w2, start = as.POSIXct("2000-01-01 15:10"))
  )
  expect_equal(table_vals(res4), c(10, 5, 5), ignore_attr = TRUE)

  expect_silent(chop_width(d1, ddays(7)))
  expect_silent(chop_width(dt1, dminutes(7)))
})


test_that("chop_width: Period", {
  skip_if_not_installed("lubridate")
  library(lubridate)

  period_w1 <- days(8)

  expect_silent(res1 <- chop_width(d1, width = period_w1))
  expect_equal(table_vals(res1), rep(8, 4), ignore_attr = TRUE)

  expect_silent(
    res2 <- chop_width(d1, period_w1, start = as.Date("1975-11-12"))
  )
  expect_equal(table_vals(res2), c(16, 8, 8), ignore_attr = TRUE)

  period_w2 <- minutes(5)

  expect_silent(res3 <- chop_width(dt1, width = period_w2))
  expect_equal(table_vals(res3), rep(5, 4), ignore_attr = TRUE)

  expect_silent(
    res4 <- chop_width(dt1, period_w2, start = as.POSIXct("2000-01-01 15:07"))
  )
  expect_equal(table_vals(res4), c(7, 5, 5, 3), ignore_attr = TRUE)

  expect_silent(chop_width(d1, days(7)))
  expect_silent(chop_width(dt1, minutes(7)))
})


test_that("chop_width: cover_tail with Period and Duration", {
  skip_if_not_installed("lubridate")

  x <- as.Date("2001-01-01") + 0:9
  expected_last <- as.Date("2001-01-10")

  period_breaks <- brk_res(brk_width(lubridate::days(4), cover_tail = FALSE), x)
  duration_breaks <- brk_res(brk_width(lubridate::ddays(4), cover_tail = FALSE), x)

  expected_fixed_last <- as.numeric(as.Date("2001-01-09"))
  expect_identical(tail(as.vector(period_breaks), 1), expected_fixed_last)
  expect_identical(tail(as.vector(duration_breaks), 1), expected_fixed_last)

  period_breaks <- brk_res(
    brk_width(lubridate::days(4), cover_tail = FALSE), x, extend = NULL
  )
  duration_breaks <- brk_res(
    brk_width(lubridate::ddays(4), cover_tail = FALSE), x, extend = NULL
  )
  expect_identical(tail(as.vector(period_breaks), 1), as.numeric(expected_last))
  expect_identical(tail(as.vector(duration_breaks), 1), as.numeric(expected_last))
})


test_that("chop_width: Period quirks", {
  skip_if_not_installed("lubridate")
  library(lubridate)

  noughties <- seq(as.Date("2000-01-01"), as.Date("2009-12-31"), by = "day")

  res1 <- chop_width(noughties, years(1))
  expect_equal(
    table_vals(res1),
    c(366, 365, 365, 365, 366, 365, 365, 365, 366, 365),
    ignore_attr = TRUE
  )

  y2k <- seq(as.Date("2000-01-01"), as.Date("2000-12-31"), by = "day")
  res2 <- chop_width(y2k, months(1))
  expect_equal(
    table_vals(res2),
    c(31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
    ignore_attr = TRUE
  )

  date_labels <- lbl_endpoints(left = FALSE, fmt = "%Y-%m-%d")

  exact_dates <- as.Date(c("2001-01-01", "2001-02-01"))
  res_brk_width <- chop(
    exact_dates,
    brk_width(months(1)),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  res_chop_width <- chop_width(
    exact_dates,
    months(1),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(levels(res_brk_width), "2001-02-01")
  expect_identical(res_brk_width, res_chop_width)

  between_dates <- as.Date(c("2001-01-01", "2001-01-31"))
  res_between <- chop_width(
    between_dates,
    months(1),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(levels(res_between), "2001-02-01")

  year2001 <- seq(as.Date("2001-01-01"), as.Date("2001-12-31"), by = "day")
  res3 <- chop_width(
    year2001,
    months(1),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(res3),
    format(seq(as.Date("2001-02-01"), as.Date("2002-01-01"), by = "month"))
  )

  res4 <- chop_width(
    year2001,
    -months(1),
    labels = lbl_endpoints(left = TRUE, fmt = "%Y-%m-%d"),
    extend = FALSE,
    drop = FALSE
  )
  expect_length(levels(res4), 12L)
  expect_equal(levels(res4)[c(1L, 12L)], c("2000-12-31", "2001-11-30"))

  res5 <- chop_width(
    as.Date(c("2001-01-31", "2001-03-30")),
    months(1),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(res5),
    c("2001-02-28", "2001-03-31")
  )

  res6 <- chop_width(
    as.Date("2001-01-01"),
    years(1),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(res6),
    "2002-01-01"
  )

  leap_years <- as.Date(c("2020-02-29", "2022-02-28"))
  res7 <- chop_width(
    leap_years,
    years(1),
    labels = date_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(levels(res7), c("2021-02-28", "2022-02-28"))
})


test_that("chop_width: Period and Duration across DST", {
  skip_if_not_installed("lubridate")
  library(lubridate)

  timezone <- "America/New_York"
  datetime_labels <- lbl_endpoints(left = FALSE, fmt = "%Y-%m-%d %H:%M %z")

  spring <- as.POSIXct(
    c("2021-03-13 00:00:00", "2021-03-16 00:00:00"),
    tz = timezone
  )
  spring_period <- chop_width(
    spring,
    days(1),
    labels = datetime_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(spring_period),
    c("2021-03-14 00:00 -0500", "2021-03-15 00:00 -0400",
      "2021-03-16 00:00 -0400")
  )

  spring_duration <- chop_width(
    spring,
    ddays(1),
    labels = datetime_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(spring_duration),
    c("2021-03-14 00:00 -0500", "2021-03-15 01:00 -0400",
      "2021-03-16 01:00 -0400")
  )

  autumn <- as.POSIXct(
    c("2021-11-06 00:00:00", "2021-11-09 00:00:00"),
    tz = timezone
  )
  autumn_period <- chop_width(
    autumn,
    days(1),
    labels = datetime_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(autumn_period),
    c("2021-11-07 00:00 -0400", "2021-11-08 00:00 -0500",
      "2021-11-09 00:00 -0500")
  )

  autumn_duration <- chop_width(
    autumn,
    ddays(1),
    labels = datetime_labels,
    extend = FALSE,
    drop = FALSE
  )
  expect_equal(
    levels(autumn_duration),
    c("2021-11-07 00:00 -0400", "2021-11-07 23:00 -0500",
      "2021-11-08 23:00 -0500", "2021-11-09 23:00 -0500")
  )
})


test_that("chop_evenly", {
  expect_silent(res1 <- chop_evenly(d1, 8))
  expect_equal(table_vals(res1), rep(4, 8), ignore_attr = TRUE)

  expect_silent(res2 <- chop_evenly(dt1, 4))
  expect_equal(table_vals(res2), rep(5, 4), ignore_attr = TRUE)

  expect_silent(chop_evenly(d1, 7))
  expect_silent(chop_evenly(dt1, 7))
})


test_that("brk_spikes", {
  d_reps <- c(rep(d1[3], 5), d1[-3])

  expect_silent(
    res <- chop(d_reps, brk_spikes(db1, n = 5))
  )

  expect_in("{1975-10-29}", levels(res))
  expect_equal(sum(res == "{1975-10-29}"), 5, ignore_attr = TRUE)
})


test_that("chop timezones", {
  dt_z1 <- seq(as.POSIXct("2000-01-01 09:00:00", tz = "GMT"),
        by = "hour", length.out = 24)
  # 8 hours behind. Hi Tom and Dan!
  dtb_z2 <- as.POSIXct("2000-01-01 12:30:00", tz = "America/Los_Angeles")

  res1 <- chop(dt_z1, dtb_z2)
  expect_equal(table_vals(res1), c(12, 12), ignore_attr = TRUE)
  # we convert breaks to the timezone of x
  expect_match(levels(res1), "20:30", fixed = TRUE)
})


test_that("Date labels", {
  li <- lbl_intervals()
  b <- brk_res(brk_default(db1), close_end = FALSE)
  expect_equal(
    li(b), "[1975-11-01, 1975-11-15)"
  , ignore_attr = TRUE)

  withr::local_options(santoku.infinity = "Inf")
  b2 <- brk_res(brk_default(db1), x = as.Date("1975-01-01"), extend = TRUE,
                close_end = FALSE)
  expect_equal(
    li(b2), c("[-Inf, 1975-11-01)", "[1975-11-01, 1975-11-15)", "[1975-11-15, Inf]")
  , ignore_attr = TRUE)

  expect_equal(
    lbl_intervals(fmt = "%y %m %d")(b),
    "[75 11 01, 75 11 15)"
  , ignore_attr = TRUE)

  expect_equal(
    lbl_dash(" to ")(b),
    "1975-11-01 to 1975-11-15"
  , ignore_attr = TRUE)

  expect_equal(
    lbl_dash(" to ", fmt = "%d/%m")(b),
    "01/11 to 15/11"
  , ignore_attr = TRUE)
})


test_that("POSIXct labels", {
  li <- lbl_intervals()
  b <- brk_res(brk_default(dtb1), close_end = FALSE)
  expect_equal(
    li(b), "[2000-01-01 15:04:00, 2000-01-01 15:14:00)"
  , ignore_attr = TRUE)

  withr::local_options(santoku.infinity = "Inf")
  b2 <- brk_res(brk_default(dtb1), x = as.POSIXct("2000-01-01 15:00:00"), extend = TRUE)
  expect_equal(
    li(b2), c("[-Inf, 2000-01-01 15:04:00)",
              "[2000-01-01 15:04:00, 2000-01-01 15:14:00)",
              "[2000-01-01 15:14:00, Inf]")
  , ignore_attr = TRUE)

  expect_equal(
    lbl_intervals(fmt = "%H:%M")(b),
    "[15:04, 15:14)"
  , ignore_attr = TRUE)

  expect_equal(
    lbl_dash(" to ")(b),
    "2000-01-01 15:04:00 to 2000-01-01 15:14:00"
  , ignore_attr = TRUE)

  expect_equal(
    lbl_dash(" to ", fmt = "%H.%M")(b),
    "15.04 to 15.14"
  , ignore_attr = TRUE)
})
