
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
    complex  = 1:3 + 1i,
    Date     = as.Date("1950-01-01") + 0:20,
    POSIXct  = as.POSIXct("2000-01-01") + 0:30
  )
  brk_funs <- list(
    brk_evenly      = brk_evenly(2),
    brk_manual      = brk_manual(1:3, rep(TRUE, 3)),
    brk_manual2     = brk_manual(1:3, c(FALSE, TRUE, FALSE)),
    brk_mean_sd     = brk_mean_sd(),
    brk_mean_sd2    = brk_mean_sd(1.96),
    brk_n           = brk_n(5),
    brk_quantiles   = brk_quantiles(1:3/4),
    brk_default     = brk_default(1:3),
    brk_default2    = brk_default(c(1, 2, 2, 3)),
    brk_width       = brk_width(1),
    brk_width2      = brk_width(1, 0),
    brk_w_difft_day = brk_width(as.difftime(5, units = "days")),
    brk_w_difft_sec = brk_width(as.difftime(5, units = "secs")),
    brk_def_Date    = brk_default(as.Date("1950-01-05") + c(0, 5)),
    brk_def_POSIXct = brk_default(as.POSIXct("2000-01-01") + c(10, 20))
  )
  lbl_funs <- list(
    lbl_dash          = lbl_dash(),
    lbl_dash2         = lbl_dash("/"),
    lbl_format        = lbl_format("%s to %s"),
    lbl_format2       = lbl_format("%s to %s", "%s..."),
    lbl_format_raw    = lbl_format("%s to %s", raw = TRUE),
    lbl_intervals     = lbl_intervals(),
    lbl_intervals_raw = lbl_intervals(raw = TRUE),
    lbl_seq           = lbl_seq("a"),
    lbl_seq2          = lbl_seq("(i)"),
    lbl_manual        = lbl_manual(letters[1:2]),
    lbl_manual2       = lbl_manual(letters[1:2], "%s)")
  )

  test_df <- expand.grid(
    x         = x_vals,
    brk_fun   = names(brk_funs),
    lbl_fun   = names(lbl_funs),
    extend    = c(TRUE, FALSE),
    left      = c(TRUE, FALSE),
    close_end = c(TRUE, FALSE),
    drop      = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )

  # remove some pointless conditions:

  skip_test <- function (cond) {
    cond <- substitute(cond)
    test_df <<- test_df[with(test_df, ! eval(cond)), ]
  }

  skip_test(! left & brk_fun == "brk_manual")
  skip_test(! left & brk_fun == "brk_manual2")
  skip_test(close_end & brk_fun == "brk_manual")
  skip_test(close_end & brk_fun == "brk_manual2")
  skip_test(! left & brk_fun == "brk_left")
  skip_test(left & brk_fun == "brk_right")

  POSIXct_breaks <- c("brk_def_POSIXct", "brk_w_difft_sec")
  Date_breaks <- c("brk_def_Date", "brk_w_difft_day")
  skip_test(names(x) == "Date" & ! brk_fun %in% Date_breaks)
  skip_test(names(x) != "Date" & brk_fun %in% Date_breaks)
  skip_test(names(x) == "POSIXct" & ! brk_fun %in% POSIXct_breaks)
  skip_test(names(x) != "POSIXct" & brk_fun %in% POSIXct_breaks)

  test_df$expect <- "succeed"
  # some things should fail
  should_fail <-   function (cond) test_df$expect[cond] <<- "error"
  should_warn <-   function (cond) test_df$expect[cond] <<- "warn"
  should_either <- function (cond) test_df$expect[cond] <<- "either"
  dont_care <-     function (cond) test_df$expect[cond] <<- NA_character_

  should_fail(names(test_df$x) == "char")
  should_fail(with(test_df,
          names(x) %in% c("same", "one") &
          brk_fun == "brk_quantiles" &
          extend == FALSE
        ))
  should_either(names(test_df$x) == "complex")


  for (r in seq_len(nrow(test_df))) {
    tdata <- test_df[r, ]
    if (is.na(tdata$expect)) next

    x <- tdata$x[[1]]
    info <- sprintf(
          "row: %s x: %s breaks: %s labels: %s extend: %s left: %s close_end: %s drop: %s",
          r, names(tdata$x), tdata$brk_fun, tdata$lbl_fun, tdata$extend,
          tdata$left, tdata$close_end, tdata$drop)

    # NA means "no error":
    regexp <- switch(tdata$expect, "succeed" = NA, NULL)
    err_class <- switch(tdata$expect, "warn" = "warning", "either" = NULL, "error")
    exp_fn <- if (tdata$expect == "error") expect_error else expect_condition
    # suppressWarnings or we drown in them:
    suppressWarnings(exp_fn(
            chop(x,
              breaks    = brk_funs[[tdata$brk_fun]],
              labels    = lbl_funs[[tdata$lbl_fun]],
              extend    = tdata$extend,
              left      = tdata$left,
              close_end = tdata$close_end,
              drop      = tdata$drop
            ),
            regexp = regexp,
            class  = err_class,
            info   = info
          ))

  }
})
