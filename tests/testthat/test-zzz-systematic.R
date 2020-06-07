
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
    brk_evenly    = brk_evenly(2),
    brk_left      = brk_left(1:3),
    brk_right     = brk_right(1:3),
    brk_manual    = brk_manual(1:3, rep(TRUE, 3)),
    brk_manual2   = brk_manual(1:3, c(FALSE, TRUE, FALSE)),
    brk_mean_sd   = brk_mean_sd(),
    brk_mean_sd2  = brk_mean_sd(1.96),
    brk_n         = brk_n(5),
    brk_quantiles = brk_quantiles(1:3/4),
    brk_default   = brk_default(1:3),
    brk_default2  = brk_default(c(1, 2, 2, 3)),
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
  test_df$expect_fail <- FALSE
  # remove some pointless conditions:
  test_df <- test_df[! (! test_df$left & test_df$brk_fun == "brk_manual"), ]
  test_df <- test_df[! (! test_df$left & test_df$brk_fun == "brk_manual2"), ]
  test_df <- test_df[! (test_df$close_end & test_df$brk_fun == "brk_manual"), ]
  test_df <- test_df[! (test_df$close_end & test_df$brk_fun == "brk_manual2"), ]
  test_df <- test_df[! (! test_df$left & test_df$brk_fun == "brk_left"), ]
  test_df <- test_df[! (test_df$left & test_df$brk_fun == "brk_right"), ]

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
      breaks    = brk_funs[[tdata$brk_fun]],
      labels    = lbl_funs[[tdata$lbl_fun]],
      extend    = tdata$extend,
      left      = tdata$left,
      close_end = tdata$close_end,
      drop      = tdata$drop
    ),
      regexp = regexp,
      info   = sprintf(
        "row: %s x: %s breaks: %s labels: %s extend: %s left: %s close_end: %s drop: %s",
        r, names(tdata$x), tdata$brk_fun, tdata$lbl_fun, tdata$extend,
        tdata$left, tdata$close_end, tdata$drop
      ))
  }
})
