#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector categorize_impl(NumericVector x, NumericVector breaks, LogicalVector left) {
  int xs = x.size();
  int bs = breaks.size();
  if (left.size() != bs) Rcpp::stop("`left` of different size to `breaks`");

  IntegerVector codes(xs, NA_INTEGER);

  int lower = 0;
  int upper = bs - 1;
  for (int i = 0; i < xs; ++i) {
    if (i == 0 || x[i] <= x[i-1]) lower = 0;
    if (i == 0 || x[i] >= x[i-1]) upper = bs - 1;
    if (x[i] < breaks[0] || (! left[0] && x[i] == breaks[0])) {
      continue;
    }
    if (x[i] > breaks[bs - 1] || (left[bs - 1] && x[i] == breaks[bs - 1])) {
      continue;
    }
    if (NumericVector::is_na(x[i]) || Rcpp::traits::is_nan<REALSXP>(x[i])) {
      continue;
    }

    int midpoint;
    while (lower < upper - 1) {
      midpoint = (int) (lower + upper)/2;
      if (x[i] > breaks[midpoint] || (left[midpoint] && x[i] == breaks[midpoint])) {
        lower = midpoint;
      } else {
        upper = midpoint;
      }
    }
    codes[i] = lower + 1;
  }

  return codes;
}


// [[Rcpp::export]]
IntegerVector categorize_impl_old(NumericVector x, NumericVector breaks, LogicalVector left) {
  int xs = x.size();
  int bs = breaks.size();
  if (left.size() != bs) Rcpp::stop("`left` of different size to `breaks`");

  IntegerVector codes(xs, NA_INTEGER);

  for (int i = 0; i < xs; ++i) {
    for (int j = 0; j < bs - 1; ++j) {
      if ((x[i] > breaks[j] || (left[j] && x[i] == breaks[j])) &&
          (x[i] < breaks[j + 1] || (! left[j + 1] && x[i] == breaks[j + 1]))) {
        codes[i] = j + 1;
        break;
      }
    }
  }

  return codes;
}