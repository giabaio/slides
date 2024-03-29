% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions.R
\name{quarto_slides}
\alias{quarto_slides}
\title{Create Quarto slides using a `gb` predefined template}
\usage{
quarto_slides(file_name, directory = here::here("slides"), style = "gb")
}
\arguments{
\item{file_name}{The file name for your .qmd file (with or without ".qmd" at
the end; the function takes care of that to avoid needing to remember
whether to include it or not!)}

\item{directory}{The directory where the files should be created.
Defaults to `here::here("slides")`. The code can handle different formats
for this string. It could be a full absolute path, eg `~/Desktop/test`, or
a relative path (eg `myslides`, which is then relative to the current
working directory). It can contain a trailing `/` or not -- if needed it
is added automatically to ensure all the relevant files can be copied
over in the right path}

\item{style}{Defaults to `gb`, but could create more, in the vain of the
`samplespace` package}
}
\description{
Create Quarto slides using a `gb` (similar to the
`xaringan` one). This function is based heavily on Cara Thompson's
package `samplespace` developed specifically for UCL Stats Science
}
\examples{
quarto_slides(file="test",directory="~/Desktop/slides-test")

}
\author{
Cara Thompson, Gianluca Baio
}
