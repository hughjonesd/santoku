% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{percent}
\alias{percent}
\title{Simple percentage formatter}
\usage{
percent(x)
}
\arguments{
\item{x}{Numeric values.}
}
\value{
\code{x} formatted as a percent.
}
\description{
\code{percent()} formats \code{x} as a percentage.
For a wider range of formatters, consider the \href{https://cran.r-project.org/package=scales}{\code{scales} package}.
}
\examples{
percent(0.5)
}
