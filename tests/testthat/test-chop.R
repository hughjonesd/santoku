
test_that("basic functionality", {
  x <- 1:3
  lbrks <- brk_manual(1:3, rep(TRUE, 3))
  rbrks <- brk_manual(1:3, rep(FALSE, 3))
  rc_brks <- brk_manual(1:3, c(TRUE, TRUE, FALSE))

  expect_equivalent(chop(x, lbrks, lbl_seq("1"), extend = FALSE),
        factor(c(1, 2, NA)))
  expect_equivalent(chop(x, rbrks, lbl_seq("1"), extend = FALSE),
        factor(c(NA, 1, 2)))
  expect_equivalent(chop(x, rc_brks, lbl_seq("1"), extend = FALSE),
        factor(c(1, 2, 2)))


})


test_that("NA, NaN and Inf", {
  y <- c(1:3, NA, NaN)
  expect_equivalent(chop(y, 1:3, lbl_seq("1"), extend = FALSE),
        factor(c(1, 2, 2, NA, NA)))

  x <- c(-Inf, 1, Inf)
  r <- chop(x, 1:2, labels = letters[1:3])
  expect_equivalent(r, factor(c("a", "b", "c"), levels = letters[1:3]))

  x <- c(-Inf, 1, Inf)
  # if extend is NULL, we should ensure even Inf is included
  r <- chop(x, brk_right(-Inf, close_end = FALSE), labels = c("-Inf", "a"))
  expect_equivalent(r, factor(c("-Inf", "a", "a"), levels = c("-Inf", "a")))
  r <- chop(x, brk_left(Inf, close_end = FALSE), labels = c("a", "Inf"))
  expect_equivalent(r, factor(c("a", "a", "Inf"), levels = c("a", "Inf")))

  # otherwise, we respect close_end = FALSE
  r <- chop(x, brk_right(c(-Inf, Inf), close_end = FALSE), labels = "a",
        extend = FALSE)
  expect_equivalent(r, factor(c(NA, "a", "a"), levels = "a"))
  r <- chop(x, brk_left(c(-Inf, Inf), close_end = FALSE), labels = "a",
        extend = FALSE)
  expect_equivalent(r, factor(c("a", "a", NA), levels = "a"))

  all_na <- rep(NA_real_, 5)
  expect_silent(chop(all_na, 1:2))
  # not sure if this should be OK or not...
  # expect_silent(chop_quantiles(all_na, c(.25, .75)))
  all_na[1] <- NaN
  expect_silent(chop(all_na, 1:2))
})


test_that("labels", {
  x <- seq(0.5, 2.5, 0.5)
  expect_equivalent(
          chop(x, 1:2, labels = letters[1:3]),
          factor(c("a", "b", "b", "b", "c"), levels = letters[1:3])
        )
  expect_error(chop(1:10, 3:4, labels = c("a", "a", "a")))
  expect_error(chop(1:10, 3:4, labels = c("a", "b")))
  expect_error(chop(1:10, 3:4, labels = c("a", "b", "c", "d")))
})


test_that("extend", {
  x <- c(1, 4)
  expect_equivalent(
          chop(x, 2:3, labels = lbl_seq("1"), extend = TRUE),
          factor(c(1, 3))
        )
  expect_equivalent(
          chop(x, 2:3, labels = lbl_seq("1"), extend = FALSE),
          factor(c(NA, NA))
        )
})


test_that("drop", {
  x <- c(1, 3)
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_seq("1"), extend = TRUE,
            drop = TRUE)),
          as.character(2:3)
        )
  expect_equivalent(
          levels(chop(x, 1:3, labels = lbl_seq("1"), extend = TRUE,
            drop = FALSE)),
          as.character(1:4)
        )
})


test_that("chop_width", {
  x <- 1:10
  expect_equivalent(
    chop_width(x, 2, labels = lbl_seq("1")),
    factor(rep(1:5, each = 2))
  )
  expect_equivalent(
    chop_width(x, 2, 0, labels = lbl_seq("1")),
    factor(c(1, rep(2:4, each = 2), 5, 5, 5))
  )
})


test_that("chop_quantiles", {
  x <- 1:6
  expect_equivalent(
          chop_quantiles(x, c(.25, .5, .75)),
          as.factor(c("[0%, 25%)", "[0%, 25%)", "[25%, 50%)", "[50%, 75%]",
            "(75%, 100%]", "(75%, 100%]"))
        )
})


test_that("chop_equally", {
  x <- 1:6
  expect_equivalent(
    chop_equally(x, 2),
    as.factor(rep(c("[0%, 50%)", "[50%, 100%]"), each = 3))
  )
})


test_that("chop_deciles", {
  x <- rnorm(100)
  expect_identical(
    chop_quantiles(x, 1:9/10),
    chop_deciles(x)
  )
})


test_that("chop_n", {
  expect_silent(res <- chop_n(rnorm(100), 10))
  expect_equivalent(as.vector(table(res)), rep(10, 10))
})


test_that("chop_mean_sd", {
  x <- -1:1 # mean 0, sd 1
  expect_silent(chop_mean_sd(x))
  expect_silent(chop_mean_sd(x, sd = 2))
  expect_error(chop_mean_sd(x, sd = 1.5), "integer")
})


test_that("fillet", {
  x <- -2:2
  expect_silent(sole <- fillet(x, -1:1))
  expect_identical(sole, chop(x, -1:1, extend = FALSE, drop = FALSE))
})


test_that("systematic tests", {
  x_vals <- list(
          ordinary = 4:1,
          real     = 4:1 + 0.5,
          NAs      = c(NA, 1:3),
          all_NAs  = c(NA_real_, NA_real_, NA_real_),
          inf      = c(-Inf, Inf, 1:3),
          inf_lo   = c(-Inf, 1:3),
          inf_hi   = c(Inf, 1:3),
          "NaN"    = c(NaN, 1:3),
          same     = rep(1, 3),
          one      = 3,
          none     = numeric(0),
          char     = letters[1:3],
          complex  = 1:3 + 1i
        )
  brk_funs <- list(
          brk_evenly    = brk_evenly(groups = 2),
          brk_left      = brk_left(1:3),
          brk_left2     = brk_left(1:3, close_end = FALSE),
          brk_left3     = brk_left(c(1, 2, 2, 3)),
          brk_manual    = brk_manual(1:3, rep(TRUE, 3)),
          brk_manual2   = brk_manual(1:3, c(FALSE, TRUE, FALSE)),
          brk_mean_sd   = brk_mean_sd(),
          brk_n         = brk_n(5),
          brk_quantiles = brk_quantiles(1:3/4),
          brk_right     = brk_right(1:3),
          brk_right2    = brk_right(1:3, close_end = FALSE),
          brk_width     = brk_width(1),
          brk_width2    = brk_width(1, 0)
        )
  lbl_funs <- list(
    lbl_dash          = lbl_dash(),
    lbl_dash2         = lbl_dash("/"),
    lbl_format        = lbl_format("%s to %s"),
    lbl_format2       = lbl_format("%s to %s", "%s..."),
    lbl_format_raw    = lbl_format("%s to %s", raw = TRUE),
    lbl_intervals     = lbl_intervals(),
    lbl_intervals_raw = lbl_intervals(raw = TRUE),
    lbl_seq           = lbl_seq(like = "a"),
    lbl_seq2          = lbl_seq(like = "(i)"),
    lbl_manual        = lbl_manual(letters[1:2]),
    lbl_manual2       = lbl_manual(letters[1:2], "%s)")
  )

  test_df <- expand.grid(
          x       = x_vals,
          brk_fun = names(brk_funs),
          lbl_fun = names(lbl_funs),
          extend  = c(TRUE, FALSE),
          drop    = c(TRUE, FALSE),
          stringsAsFactors = FALSE
        )
  test_df$expect_fail <- FALSE

  # some things should fail
  ef <- function (cond) test_df$expect_fail[cond] <<- TRUE
  ef(names(test_df$x) == "char")
  ef(names(test_df$x) == "complex")
  ef(
          names(test_df$x) %in% c("same", "one") &
          test_df$brk_fun == "brk_quantiles" &
          test_df$extend == FALSE
        )

  for (r in seq_len(nrow(test_df))) {
    tdata <- test_df[r, ]
    regexp <- if (tdata$expect_fail) NULL else NA # NA means "no error"
    x <- tdata$x[[1]]
    # expect_silent doesn't handle !! for labeling nicely
    expect_error(chop(x,
                  breaks = brk_funs[[tdata$brk_fun]],
                  labels = lbl_funs[[tdata$lbl_fun]],
                  extend = tdata$extend,
                  drop   = tdata$drop
                ),
                regexp = regexp,
                info   = sprintf(
                  "row: %s x: %s breaks: %s labels: %s extend %s drop: %s",
                  r, names(tdata$x), tdata$brk_fun, tdata$lbl_fun, tdata$extend,
                  tdata$drop
                ))
  }
})
