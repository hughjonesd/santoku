#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector categorize_impl(NumericVector x, NumericVector breaks, LogicalVector left) {
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
