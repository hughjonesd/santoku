#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector categorize(NumericVector x, NumericVector breaks) {
  int xs = x.size();
  int bs = breaks.size();
  LogicalVector left = breaks.attr("left");
  if (left.size() != bs) Rcpp::stop("`left` of different size to `breaks`");

  IntegerVector codes(xs, NA_INTEGER);

  for (int i = 0; i < xs; ++i) {
    int lower = 0;
    int upper = bs - 1;
    if (x[i] < breaks[lower] || (! left[lower] && x[i] == breaks[lower])) {
      continue;
    }
    if (x[i] > breaks[upper] || (left[upper] && x[i] == breaks[upper])) {
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
IntegerVector old_categorize(NumericVector x, NumericVector breaks) {
  int xs = x.size();
  int bs = breaks.size();
  LogicalVector left = breaks.attr("left");
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

