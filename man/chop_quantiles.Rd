% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chop-by-group-size.R, R/breaks-by-group-size.R,
%   R/tab.R
\name{chop_quantiles}
\alias{chop_quantiles}
\alias{chop_deciles}
\alias{brk_quantiles}
\alias{tab_quantiles}
\alias{tab_deciles}
\title{Chop by quantiles}
\usage{
chop_quantiles(
  x,
  probs,
  ...,
  labels = if (raw) lbl_intervals() else lbl_intervals(single = NULL),
  left = is.numeric(x),
  raw = FALSE,
  weights = NULL,
  recalc_probs = FALSE
)

chop_deciles(x, ...)

brk_quantiles(probs, ..., weights = NULL, recalc_probs = FALSE)

tab_quantiles(x, probs, ..., left = is.numeric(x), raw = FALSE)

tab_deciles(x, ...)
}
\arguments{
\item{x}{A vector.}

\item{probs}{A vector of probabilities for the quantiles. If \code{probs} has
names, these will be used for labels.}

\item{...}{For \code{chop_quantiles}, passed to \code{\link[=chop]{chop()}}. For \code{brk_quantiles()},
passed to \code{\link[stats:quantile]{stats::quantile()}} or \code{\link[Hmisc:wtd.stats]{Hmisc::wtd.quantile()}}.}

\item{labels}{A character vector of labels or a function to create labels.}

\item{left}{Logical. Left-closed or right-closed breaks?}

\item{raw}{Logical. Use raw values in labels?}

\item{weights}{\code{NULL} or numeric vector of same length as \code{x}. If not
\code{NULL}, \code{\link[Hmisc:wtd.stats]{Hmisc::wtd.quantile()}} is used to calculate weighted quantiles.}

\item{recalc_probs}{Logical. Recalculate probabilities of quantiles using
\code{\link[stats:ecdf]{ecdf(x)}}? See below.}
}
\value{
\verb{chop_*} functions return a \code{\link{factor}} of the same length as \code{x}.

\verb{brk_*} functions return a \code{\link{function}} to create \code{breaks}.

\verb{tab_*} functions return a contingency \code{\link[=table]{table()}}.
}
\description{
\code{chop_quantiles()} chops data by quantiles.
\code{chop_deciles()} is a convenience function which chops into deciles.
}
\details{
For non-numeric \code{x}, \code{left} is set to \code{FALSE} by default. This works better
for calculating "type 1" quantiles, since they round down. See
\code{\link[stats:quantile]{stats::quantile()}}.

By default, \code{chop_quantiles()} shows the requested probabilities in the
labels. To show the numeric quantiles themselves, set \code{raw = TRUE}.

When \code{x} contains duplicates, consecutive quantiles may be the same number. If
so, interval labels may be misleading, and if \code{recalc_probs = FALSE} a warning is
emitted. Set \code{recalc_probs = TRUE} to recalculate the probabilities of the quantiles
using the \link[stats:ecdf]{empirical cumulative distribution function} of \code{x}.
Doing so may give you different labels from what you expect, and will
remove any names from \code{probs}, but it never changes the actual
quantiles used for breaks. At present, \code{recalc_probs = TRUE} is incompatible
with non-null \code{weights}. See the example below.
}
\examples{
chop_quantiles(1:10, 1:3/4)

chop_quantiles(1:10, c(Q1 = 0, Q2 = 0.25, Q3 = 0.5, Q4 = 0.75))

chop(1:10, brk_quantiles(1:3/4))

chop_deciles(1:10)

# to label by the quantiles themselves:
chop_quantiles(1:10, 1:3/4, raw = TRUE)

# duplicate quantiles:
x <- c(1, 1, 1, 2, 3)
quantile(x, 1:5/5)
tab_quantiles(x, 1:5/5)
tab_quantiles(x, 1:5/5, recalc_probs = TRUE)
set.seed(42)
tab_quantiles(rnorm(100), probs = 1:3/4, raw = TRUE)

}
\seealso{
Other chopping functions: 
\code{\link{chop}()},
\code{\link{chop_equally}()},
\code{\link{chop_evenly}()},
\code{\link{chop_fn}()},
\code{\link{chop_mean_sd}()},
\code{\link{chop_n}()},
\code{\link{chop_proportions}()},
\code{\link{chop_spikes}()},
\code{\link{chop_width}()},
\code{\link{fillet}()}
}
\concept{chopping functions}
