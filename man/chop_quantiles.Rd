% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chop.R, R/breaks.R
\name{chop_quantiles}
\alias{chop_quantiles}
\alias{chop_deciles}
\alias{chop_equally}
\alias{brk_quantiles}
\alias{brk_equally}
\title{Chop by quantiles}
\usage{
chop_quantiles(x, probs, ..., left = is.numeric(x), close_end = TRUE)

chop_deciles(x, ...)

chop_equally(x, groups, ..., left = is.numeric(x), close_end = TRUE)

brk_quantiles(probs, ...)

brk_equally(groups)
}
\arguments{
\item{x}{A numeric vector.}

\item{probs}{A vector of probabilities for the quantiles.}

\item{...}{Passed to \code{\link[=chop]{chop()}}, or for \code{brk_quantiles} to \code{\link[stats:quantile]{stats::quantile()}}.}

\item{left}{Passed to \code{\link[=chop]{chop()}}.}

\item{close_end}{Passed to \code{\link[=chop]{chop()}}.}

\item{groups}{Number of groups.}
}
\value{
For  \verb{chop_*} functions, a factor of the same length as \code{x}.
}
\description{
\code{chop_quantiles} chops data by quantiles. \code{chop_equally} chops
data into equal-sized groups. \code{chop_deciles} is a convenience shortcut and
chops into deciles.
}
\details{
Note that these functions set \code{close_end = TRUE} by default.
This helps ensure that e.g. \verb{chop_quantiles(x, c(0, 1/3, 2/3, 1)}
will split the data into three equal-sized groups.

For non-numeric \code{x}, \code{left} is set to \code{FALSE} by default. This works better
for calculating "type 1" quantiles, since they round down. See
\code{\link[stats:quantile]{stats::quantile()}}.
}
\examples{
chop_quantiles(1:10, 1:3/4)

chop(1:10, brk_quantiles(1:3/4))

chop_deciles(1:10)

chop_equally(1:10, 5)

# to label by the quantiles themselves:
chop_quantiles(1:10, 1:3/4, lbl_intervals(raw = TRUE))

}
\seealso{
Other chopping functions: 
\code{\link{chop_mean_sd}()},
\code{\link{chop_n}()},
\code{\link{chop_width}()},
\code{\link{chop}()},
\code{\link{fillet}()}
}
\concept{chopping functions}
