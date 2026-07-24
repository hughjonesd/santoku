test_that("exported casting methods keep their interface", {
  methods <- c(
    "default", "double", "Date", "POSIXct", "ts", "zoo", "integer64",
    "hexmode", "octmode"
  )

  for (method in methods) {
    fn <- get(paste0("santoku_cast_common.", method), asNamespace("santoku"))
    expect_identical(names(formals(fn)), c("x", "y"))
  }
})


test_that("base types cast as before", {
  expect_equal(
    santoku_cast_common.default(1L, 2),
    list(1, 2)
  )
  expect_equal(
    santoku_cast_common.double(1, 2L),
    list(1, 2)
  )
  expect_equal(
    santoku_cast_common.default(letters[1:2], letters[2:3]),
    list(letters[1:2], letters[2:3])
  )

  ordered_x <- ordered(1:2, levels = 1:3)
  expect_equal(
    santoku_cast_common.default(ordered_x, ordered_x),
    list(ordered_x, ordered_x)
  )

  versions <- as.package_version(c("1.0", "2.0"))
  expect_equal(
    santoku_cast_common.default(versions, versions),
    list(versions, versions)
  )
})


test_that("dates and date-times cast as before", {
  dates <- as.Date("2020-01-01") + 0:1
  times <- as.POSIXct(dates, tz = "UTC")

  expect_equal(santoku_cast_common.Date(dates, dates), list(dates, dates))
  expect_equal(
    santoku_cast_common.Date(dates, times),
    list(as.POSIXct(dates), times)
  )
  expect_equal(
    santoku_cast_common.POSIXct(times, dates),
    list(times, as.POSIXct(dates))
  )

  deltas <- as.difftime(1:2, units = "days")
  expect_equal(
    santoku_cast_common.default(deltas, deltas),
    list(deltas, deltas)
  )
})


test_that("base wrapper classes cast as before", {
  series <- ts(1:2)
  cast_series <- santoku_cast_common.ts(series, 2:3)
  expect_false(inherits(cast_series[[1]], "ts"))
  expect_equal(as.numeric(cast_series[[1]]), 1:2)

  hex <- as.hexmode(1:2)
  oct <- as.octmode(1:2)
  expect_equal(santoku_cast_common.hexmode(hex, hex), list(hex, hex))
  expect_equal(santoku_cast_common.octmode(oct, oct), list(oct, oct))
  expect_equal(
    santoku_cast_common.hexmode(hex, 2:3),
    list(as.numeric(hex), as.numeric(2:3))
  )
})


test_that("suggested wrapper classes cast as before", {
  skip_if_not_installed("bit64")
  integers <- bit64::as.integer64(1:2)
  expect_equal(
    santoku_cast_common.integer64(integers, integers),
    list(integers, integers)
  )
  expect_equal(
    santoku_cast_common.integer64(integers, c(1.5, 2.5)),
    list(as.double(integers), c(1.5, 2.5))
  )

  skip_if_not_installed("zoo")
  zoo_x <- zoo::zoo(1:2, 1:2)
  expect_equal(
    santoku_cast_common.zoo(zoo_x, 2:3),
    list(1:2, 2:3)
  )

  skip_if_not_installed("xts")
  xts_x <- xts::xts(1:2, as.Date("2020-01-01") + 0:1)
  expect_equal(
    santoku_cast_common.zoo(xts_x, 2:3),
    list(matrix(1:2), matrix(2:3))
  )
})


test_that("units cast as before", {
  skip_if_not_installed("units")
  x <- units::set_units(1:2, cm)
  y <- units::set_units(10:20, mm)

  cast <- santoku_cast_common.default(x, y)
  expect_equal(cast[[1]], x)
  expect_equal(cast[[2]], units::set_units(seq(1, 2, by = 0.1), cm))
})
