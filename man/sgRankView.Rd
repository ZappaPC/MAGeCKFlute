% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sgRankView.R
\docType{methods}
\name{sgRankView}
\alias{sgRankView}
\title{View the rank of sgRNA points in horizontal bars.}
\usage{
sgRankView(df, genelist = NULL, top = 3, bottom = 3,
  neg_ctrl = NULL, binwidth = 5, line.size = 1, filename = NULL,
  width = 5, height = 3.5, ...)
}
\arguments{
\item{df}{A data frame, which contains columns of 'sgrna', 'Gene', and 'LFC'.}

\item{genelist}{Character vector, specifying genes to be plotted.}

\item{top}{Integer, specifying number of top genes to be plotted.}

\item{bottom}{Integer, specifying number of bottom genes to be plotted.}

\item{neg_ctrl}{A vector of negative ctrl genes.}

\item{binwidth}{A numeric value specifying the bar width,}

\item{line.size}{A numeric value specifying the size of segment lines.}

\item{filename}{Figure file name to create on disk. Default filename="NULL", which means no output.}

\item{width}{As in ggsave.}

\item{height}{As in ggsave.}

\item{...}{Other available parameters in function 'ggsave'.}
}
\value{
An object created by \code{ggplot}.
}
\description{
View the rank of sgRNA points in horizontal bars.
}
\examples{
data(rra.sgrna_summary)
sgrra = ReadsgRRA(rra.sgrna_summary)
sgRankView(sgrra)

}
\author{
Wubing Zhang
}
