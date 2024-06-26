% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/labels.R
\name{lbl_intervals}
\alias{lbl_intervals}
\title{Label chopped intervals using set notation}
\usage{
lbl_intervals(
  fmt = NULL,
  single = "{{{l}}}",
  first = NULL,
  last = NULL,
  raw = FALSE
)
}
\arguments{
\item{fmt}{String, list or function. A format for break endpoints.}

\item{single}{Glue string: label for singleton intervals. See \code{\link[=lbl_glue]{lbl_glue()}}
for details. If \code{NULL}, singleton intervals will be labelled the same way
as other intervals.}

\item{first}{Glue string: override label for the first category. Write e.g.
\code{first = "<{r}"} to create a label like \code{"<18"}. See \code{\link[=lbl_glue]{lbl_glue()}}
for details.}

\item{last}{String: override label for the last category. Write e.g.
\code{last = ">{l}"} to create a label like \code{">65"}. See \code{\link[=lbl_glue]{lbl_glue()}}
for details.}

\item{raw}{\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}. Use the \code{raw} argument to \code{\link[=chop]{chop()}}
instead.}
}
\value{
A function that creates a vector of labels.
}
\description{
These labels are the most exact, since they show you whether
intervals are "closed" or "open", i.e. whether they include their endpoints.
}
\details{
Mathematical set notation looks like this:
\itemize{
\item \code{[a, b]}: all numbers \code{x} where \verb{a <= x <= b};
\item \code{(a, b)}: all numbers where \verb{a < x < b};
\item \code{[a, b)}: all numbers where \verb{a <= x < b};
\item \code{(a, b]}: all numbers where \verb{a < x <= b};
\item \code{{a}}: just the number \code{a} exactly.
}
}
\section{Formatting endpoints}{


If \code{fmt} is not \code{NULL} then it is used to format the endpoints.
\itemize{
\item If \code{fmt} is a string, then numeric endpoints will be formatted by
\code{sprintf(fmt, breaks)}; other endpoints, e.g. \link{Date} objects, will be
formatted by \code{format(breaks, fmt)}.
\item If \code{fmt} is a list, then it will be used as arguments to \link{format}.
\item If \code{fmt} is a function, it should take a vector of numbers (or other objects
that can be used as breaks) and return a character vector. It may be helpful
to use functions from the \code{{scales}} package, e.g. \code{\link[scales:label_number]{scales::label_comma()}}.
}
}

\examples{

tab(-10:10, c(-3, 0, 0, 3),
      labels = lbl_intervals())

tab(-10:10, c(-3, 0, 0, 3),
      labels = lbl_intervals(fmt = list(nsmall = 1)))

tab_evenly(runif(20), 10,
      labels = lbl_intervals(fmt = percent))

}
\seealso{
Other labelling functions: 
\code{\link{lbl_dash}()},
\code{\link{lbl_discrete}()},
\code{\link{lbl_endpoints}()},
\code{\link{lbl_glue}()},
\code{\link{lbl_manual}()},
\code{\link{lbl_midpoints}()},
\code{\link{lbl_seq}()}
}
\concept{labelling functions}
