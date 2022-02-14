

test_that("character", {
  x <- LETTERS
  br <- c("F", "M")
  expect_warning(
    chop(x, br)
  )
})


test_that("unit from units package", {
  loadNamespace("units")
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
})


test_that("package_version", {
  x <- as.package_version(c("0.5", "0.5.1", "1.0", "1.1.1", "1.2.0"))
  br <- as.package_version(c("0.7", "1.1", "1.2.0"))

  expect_silent(
    chop(x, br)
  )
})
