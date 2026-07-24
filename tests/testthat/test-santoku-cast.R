test_that("base types cast as before", {
  expect_equal(
    santoku_cast_common(1L, 2),
    list(1, 2)
  )
  expect_equal(
    santoku_cast_common(1, 2L),
    list(1, 2)
  )
  expect_equal(
    santoku_cast_common(letters[1:2], letters[2:3]),
    list(letters[1:2], letters[2:3])
  )

  ordered_x <- ordered(1:2, levels = 1:3)
  expect_equal(
    santoku_cast_common(ordered_x, ordered_x),
    list(ordered_x, ordered_x)
  )

  versions <- as.package_version(c("1.0", "2.0"))
  expect_equal(
    santoku_cast_common(versions, versions),
    list(versions, versions)
  )
})


test_that("dates and date-times cast as before", {
  dates <- as.Date("2020-01-01") + 0:1
  times <- as.POSIXct(dates, tz = "UTC")

  expect_equal(santoku_cast_common(dates, dates), list(dates, dates))
  expect_equal(
    santoku_cast_common(dates, times),
    list(as.POSIXct(dates), times)
  )
  expect_equal(
    santoku_cast_common(times, dates),
    list(times, as.POSIXct(dates))
  )

  deltas <- as.difftime(1:2, units = "days")
  expect_equal(
    santoku_cast_common(deltas, deltas),
    list(deltas, deltas)
  )
})


test_that("base wrapper classes cast as before", {
  series <- ts(1:2)
  cast_series <- santoku_cast_common(series, 2:3)
  expect_false(inherits(cast_series[[1]], "ts"))
  expect_equal(as.numeric(cast_series[[1]]), 1:2)

  hex <- as.hexmode(1:2)
  oct <- as.octmode(1:2)
  expect_equal(santoku_cast_common(hex, hex), list(hex, hex))
  expect_equal(santoku_cast_common(oct, oct), list(oct, oct))
  expect_equal(
    santoku_cast_common(hex, 2:3),
    list(as.numeric(hex), as.numeric(2:3))
  )
})


test_that("suggested wrapper classes cast as before", {
  skip_if_not_installed("bit64")
  integers <- bit64::as.integer64(1:2)
  expect_equal(
    santoku_cast_common(integers, integers),
    list(integers, integers)
  )
  expect_equal(
    santoku_cast_common(integers, c(1.5, 2.5)),
    list(as.double(integers), c(1.5, 2.5))
  )

  skip_if_not_installed("zoo")
  zoo_x <- zoo::zoo(1:2, 1:2)
  expect_equal(
    santoku_cast_common(zoo_x, 2:3),
    list(1:2, 2:3)
  )

  skip_if_not_installed("xts")
  xts_x <- xts::xts(1:2, as.Date("2020-01-01") + 0:1)
  expect_equal(
    santoku_cast_common(xts_x, 2:3),
    list(matrix(1:2), matrix(2:3))
  )
})


test_that("units cast as before", {
  skip_if_not_installed("units")
  x <- units::set_units(1:2, cm)
  y <- units::set_units(10:20, mm)

  cast <- santoku_cast_common(x, y)
  expect_equal(cast[[1]], x)
  expect_equal(cast[[2]], units::set_units(seq(1, 2, by = 0.1), cm))
})
