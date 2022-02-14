
test_that("units from units package", {
  loadNamespace("units")
  x <- units::set_units(1:10, cm)
  br <- units::set_units(c(3, 5, 5, 8), cm)

  expect_silent(
    chop(x, br)
  )
})


test_that("package_version", {
  x <- as.package_version(c("0.5", "0.5.1", "1.0", "1.1.1", "1.2.0"))
  br <- as.package_version(c("0.7", "1.1", "1.2.0"))

  expect_silent(
    chop(x, br)
  )
})
