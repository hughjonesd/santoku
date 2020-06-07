
# for brk_ functions:
brk_res <- function (
             brk_fun,
             x         = 1:2,
             extend    = FALSE,
             left      = TRUE,
             close_end = FALSE
           ) {
  brk_fun(x, extend = extend, left = left, close_end = close_end)
}
