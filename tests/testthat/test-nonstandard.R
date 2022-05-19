

test_that("character", {
  x <- LETTERS
  br <- c("F", "M")
  expect_warning(
    chop(x, br)
  )

  oo <- options(santoku.warn_character = FALSE)
  on.exit(options(oo))

  expect_silent(
    chop(x, br)
  )

  expect_silent(
    chop_equally(x, 13)
  )

  expect_silent(
    chop_n(x, 13)
  )
})


test_that("ordered", {
  x <- ordered(1:10)
  br <- ordered(c(5, 8), levels = levels(x))

  expect_silent(
    chop(x, br)
  )

  expect_silent(
    chop_n(x, 5)
  )

  expect_silent(
    chop_equally(x, groups = 2)
  )
})


test_that("hexmode", {
  x <- as.hexmode(1:10 + 10)
  br <- as.hexmode(c(13, 15, 15, 18))

  expect_silent(
    chop(x, br, extend = FALSE)
  )

  skip("vctrs can't cast hexmode and integer")
  expect_silent(
    chop(x, br)
  )
})


test_that("stat::ts", {
  x <- ts(1:10)
  # note: we need to specify integer breaks
  # vec_cast can't cope with ts(<integer>) and ts(<double>)
  br <- c(5L, 8L)

  expect_silent(
    chop(x, br)
  )

  x <- ts(c(1.0, 3.0, 5.0))
  br <- c(2.0, 4.0)
  expect_silent(
    chop(x, br)
  )

  expect_silent(
    chop_equally(x, groups = 3)
  )

  expect_silent(
    chop_width(x, width = 2)
  )

  skip("Can't cope with mixed integer/double ts objects")

  x <- ts(1:10)
  br <- ts(c(5.0, 8.0))
  expect_silent(
    chop(x, br)
  )
})


test_that("units::units", {
  skip_if_not_installed("units")

  x <- units::set_units(1:10, cm)
  br <- units::set_units(c(3, 5, 5, 8), cm)
  br_mm <- units::set_units(c(30, 50, 50, 80), mm)
  expect_silent(
    chop(x, br)
  )

  expect_equal(
    as.numeric(chop(x, br_mm)),
    c(1, 1, 2, 2, 3, 4, 4, 5, 5, 5)
  )

  br_m2 <- units::set_units(c(3,5,5,8), m^2)
  expect_error(
    chop(x, br_m2)
  )

  expect_silent(
    chopped <- chop_width(x, units::set_units(0.05, m))
  )
  expect_equal(
    as.numeric(chopped), c(rep(1, 5), rep(2, 5))
  )

  start <- units::set_units(20, mm)
  expect_silent(
    chopped <- chop_width(x, units::set_units(0.05, m), start)
  )
  expect_equal(
    as.numeric(chopped), c(1, rep(2, 5), rep(3, 4))
  )

  expect_silent(
    chopped <- chop_evenly(x, intervals = 2)
  )
  expect_equal(
    as.numeric(chopped), c(rep(1, 5), rep(2, 5))
  )

  expect_silent(
    chop_equally(x, 5)
  )

  expect_silent(
    chop_n(x, 3)
  )

  expect_silent(
    chop(x, br, labels = lbl_discrete(unit = units::set_units(1, cm)))
  )

  # we don't support mixed units, since units doesn't support
  # comparison operators on those
})


test_that("package_version", {
  x <- as.package_version(c("0.5", "0.5.1", "1.0", "1.1.1", "1.2.0"))
  br <- as.package_version(c("0.7", "1.1", "1.2.0"))

  expect_silent(
    chop(x, br)
  )
})


test_that("difftime", {
  days <- as.Date("1970-01-01") + 0:30
  difftimes_d <- days[10:15] - days[12:7]
  difftimes_h <- difftimes_d
  units(difftimes_h) <- "hours"

  expect_silent(
    chop(difftimes_d, difftimes_d[c(3,5)])
  )

  expect_silent(
    chop(difftimes_d, difftimes_h)
  )
})


test_that("bit64", {
  skip_if_not_installed("bit64")

  x64 <- bit64::as.integer64(1:10)
  b64 <- bit64::as.integer64(c(3, 5, 5, 7))

  expect_silent(
    chop(x64, b64)
  )

  expect_silent(
    chopped <- chop(x64, b64, extend = TRUE)
  )
  expect_equivalent(
    as.numeric(chopped),
    c(1, 1, 2, 2, 3, 4, 5, 5, 5, 5)
  )

  expect_silent(
    chop(1:10, b64)
  )

  expect_silent(
    chop(x64, as.integer(c(3, 5, 5, 7)))
  )

  skip("vec_cast_common doesn't like double and integer64")

  expect_silent(
    chop(x64, c(3, 5, 5, 7))
  )

  expect_silent(
    chop(c(1, 3, 5, 7), b64)
  )
})

test_that("hms::hms", {
  skip_if_not_installed("hms")

  x <- hms::hms(minutes = 1:180)
  br <- hms::hms(hours = 1:2)

  expect_silent(
    chopped <- chop(x, br)
  )
  expect_equal(
    as.numeric(chopped),
    rep(1:3, c(59, 60, 61)),
    ignore_attr = TRUE
  )
})


test_that("haven::labelled", {
  skip_if_not_installed("haven")

  x <- haven::labelled(1:10, c("Lo" = 1, "Hi" = 10))
  br <- haven::labelled(c(3, 5), c("Mid" = 3, "Mid2" = 5))

  expect_silent(
    chop(x, c(2, 5, 5, 8))
  )

  expect_silent(
    chop(x, br)
  )
})