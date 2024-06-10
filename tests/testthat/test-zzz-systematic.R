
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
    brk_evenly      = expression(brk_evenly(2)),
    brk_proportions = expression(brk_proportions(c(0.25, 0.6))),
    brk_manual      = expression(brk_manual(1:3, c(FALSE, TRUE, FALSE))),
    brk_mean_sd     = expression(brk_mean_sd()),
    brk_pretty      = expression(brk_pretty()),
    brk_n           = expression(brk_n(5)),
    brk_n_merge     = expression(brk_n(5, tail = "merge")),
    brk_quantiles   = expression(brk_quantiles(1:3/4)),
    brk_default     = expression(brk_default(1:3)),
    brk_default2    = expression(brk_default(c(1, 2, 2, 3))),
    brk_default_lo  = expression(brk_default(1)),
    brk_default_hi  = expression(brk_default(5)),
    brk_width       = expression(brk_width(1)),
    brk_width2      = expression(brk_width(1, 0)),
    brk_spikes  = expression(brk_spikes(1:3, n = 2)),
    brk_w_difft_day = expression(brk_width(as.difftime(5, units = "days"))),
    brk_w_difft_sec = expression(brk_width(as.difftime(5, units = "secs"))),
    brk_def_Date    = expression(brk_default(as.Date("1950-01-05") + c(0, 5))),
    brk_def_POSIXct = expression(brk_default(as.POSIXct("2000-01-01") + c(10, 20)))
  )
  lbl_funs <- list(
    lbl_dash          = expression(lbl_dash()),
    lbl_intervals     = expression(lbl_intervals()),
    lbl_seq           = expression(lbl_seq("a")),
    lbl_endpoints     = expression(lbl_endpoints()),
    lbl_midpoints     = expression(lbl_midpoints())
  )

  test_df <- expand.grid(
    x         = x_vals,
    brk_fun   = names(brk_funs),
    lbl_fun   = names(lbl_funs),
    # we translate NA to NULL in chop(); doing this means we don't need a list():
    extend    = c(TRUE, FALSE, NA),
    left      = c(TRUE, FALSE),
    close_end = c(TRUE, FALSE),
    # ditto:
    raw       = c(TRUE, FALSE, NA),
    drop      = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )

  # remove some pointless conditions:

  skip_test <- function (cond) {
    cond <- substitute(cond)
    test_df <<- test_df[with(test_df, ! eval(cond)), ]
  }

  skip_test(! left & brk_fun == "brk_manual")
  skip_test(! close_end & brk_fun == "brk_manual")

  POSIXct_breaks <- c("brk_def_POSIXct", "brk_w_difft_sec")
  Date_breaks <- c("brk_def_Date", "brk_w_difft_day")
  skip_test(names(x) %in% c("Date", "POSIXct")  &
              ! brk_fun %in% c(Date_breaks, POSIXct_breaks))
  skip_test(! names(x) %in% c("Date", "POSIXct") &
              brk_fun %in% c(Date_breaks, POSIXct_breaks))
  # don't try to break dates by 1 second width (very slow!)
  skip_test(names(x) != "POSIXct" & brk_fun == "brk_w_difft_sec")

  test_df$expect <- "succeed"
  test_df$row <- seq_len(nrow(test_df))

  # some things should fail
  should_fail <-   function (cond) test_df$expect[cond] <<- "error"
  should_warn <-   function (cond) test_df$expect[cond] <<- "warn"
  should_either <- function (cond) test_df$expect[cond] <<- "either"
  dont_care <-     function (cond) test_df <<- test_df[! cond, ]

  should_fail(names(test_df$x) == "char")

  # but if we break by quantities, OK...
  char_by_quantities <- names(test_df$x) == "char" &
          test_df$brk_fun %in% c("brk_equally", "brk_quantiles", "brk_n",
                                 "brk_n_merge")
  # so long as we aren't trying raw midpoints
  raw <- ! is.na(test_df$raw) & test_df$raw
  should_warn(char_by_quantities & !
                (test_df$lbl_fun == "lbl_midpoints" & raw)
  )
  # ... or midpoints with brk_n()
  should_fail(char_by_quantities & test_df$lbl_fun == "lbl_midpoints"
              & test_df$brk_fun %in% c("brk_n", "brk_n_merge"))

  # brk_default_hi and _lo have a single break, so if you can't
  # extend it, there are no possible intervals:
  should_fail(with(test_df,
          brk_fun %in% c("brk_default_hi", "brk_default_lo") &
          extend == FALSE
        ))

  # ditto when extend is NULL and there's no non-NA data
  # here we have to fail even though with some data we'd be OK
  should_fail(with(test_df,
                    brk_fun %in% c("brk_default_hi", "brk_default_lo") &
                    names(x) %in% c("all_NAs", "none") &
                    is.na(extend)
  ))

  # raw endpoints get duplicated if multiple quantiles are infinite:
  dont_care(with(test_df,
                   names(x) %in% c("inf_lo", "inf_hi") &
                   brk_fun == "brk_quantiles" &
                   lbl_fun == "lbl_midpoints" &
                   raw == TRUE &
                   extend == TRUE &
                   close_end == FALSE
                 ))
  dont_care(with(test_df,
                   names(x) == "inf_lo" &
                   brk_fun == "brk_quantiles" &
                   lbl_fun == "lbl_endpoints" &
                   raw == TRUE &
                   extend == TRUE &
                   left == FALSE &
                   close_end == FALSE
                 ))

  # lbl_endpoints() can create duplicates
  # when you extend an open interval to add a singleton
  # e.g. {1}, (1, 2]
  dont_care(with(test_df,
                   lbl_fun == "lbl_endpoints" &
                   left == FALSE & is.na(extend)
                 ))
  dont_care(with(test_df,
                   lbl_fun == "lbl_endpoints" &
                   brk_fun %in% c("brk_default_lo", "brk_manual") &
                   left == TRUE & is.na(extend)
                 ))

  # quantiles here likely to create duplicate endpoints
  dont_care(with(test_df,
                 names(x) %in% c("one", "same", "char") &
                 lbl_fun == "lbl_endpoints" &
                 brk_fun == "brk_quantiles" &
                 extend == TRUE & raw == TRUE
               ))

  # brk_quantiles() should warn on duplicate quantiles
  should_warn(with(test_df,
                 names(x) %in% c("one", "same") &
                 brk_fun == "brk_quantiles"
               ))

  # brk_default has breaks 1,2,2,3
  # with lbl_endpoints, this may create duplicate left endpoints
  # ie the user asked for something we can't do
  dont_care(with(test_df,
          names(x) %in%
            c("ordinary", "inf", "inf_lo", "inf_hi", "NaN", "NAs") &
          brk_fun == "brk_default2" &
          lbl_fun == "lbl_endpoints"
        ))
  dont_care(with(test_df,
          brk_fun == "brk_default2" &
          lbl_fun == "lbl_endpoints" &
          drop == FALSE
        ))
  dont_care(with(test_df,
          brk_fun == "brk_spikes" &
          lbl_fun == "lbl_endpoints" &
          drop == FALSE
        ))
  dont_care(with(test_df,
          brk_fun %in% c("brk_n", "brk_n_merge") &
          lbl_fun == "lbl_endpoints"
        ))

  # lbl_midpoints struggles with Inf for obvious reasons
  dont_care(with(test_df,
          names(x) %in% c("inf", "inf_lo", "inf_hi") &
          brk_fun %in% c("brk_n", "brk_n_merge") &
          lbl_fun == "lbl_midpoints"
        ))

  should_fail(names(test_df$x) == "complex")

  # we sample the same 10000 rows every day
  seed <- as.numeric(Sys.Date())
  set.seed(seed)
  test_everything <- isTRUE(as.logical(Sys.getenv("CI"))) ||
                              getOption("santoku.test_everything", FALSE)

  sample_rows <- if (test_everything) {
                   seq_len(nrow(test_df))
                 } else {
                   sort(sample(nrow(test_df), 10000, replace = FALSE))
                 }

  for (r in sample_rows) {
    tdata <- test_df[r, ]
    if (is.na(tdata$expect)) next

    # v basic debugging interactively. Replace r by the row that gives a test failure
    # cat(r, "\n")
    # if (r==63194) browser()
    if (is.na(tdata$extend)) tdata$extend <- NULL
    if (is.na(tdata$raw)) tdata$raw <- NULL

    x <- tdata$x[[1]]
    format_null <- function (x) if (is.null(x)) "NULL" else x
    info <- sprintf(
          "seed: %s row: %s
          command: chop(%s, %s, labels = %s, extend = %s, left = %s,
                     close_end = %s, raw = %s, drop = %s)",
          seed, tdata$row, tdata$x, as.character(brk_funs[[tdata$brk_fun]]),
          as.character(lbl_funs[[tdata$lbl_fun]]), format_null(tdata$extend),
          tdata$left, tdata$close_end, format_null(tdata$raw), tdata$drop)

    # NA means "no error":
    regexp <- switch(tdata$expect, "succeed" = NA, NULL)
    err_class <- switch(tdata$expect, "warn" = "warning", "either" = NULL, "error")
    exp_fn <- if (tdata$expect == "error") expect_error else expect_condition
    # suppressWarnings or we drown in them:

    suppressWarnings(exp_fn(
            chop(!!x,
              breaks    = eval(brk_funs[[!!tdata$brk_fun]]),
              labels    = eval(lbl_funs[[!!tdata$lbl_fun]]),
              extend    = !!tdata$extend,
              left      = !!tdata$left,
              close_end = !!tdata$close_end,
              raw       = !!tdata$raw,
              drop      = !!tdata$drop
            ),
            regexp = regexp,
            class  = err_class,
            info   = info
          ))
  }
})

