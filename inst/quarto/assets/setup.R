#########################################
# Set up and common commands & packages #
#########################################
# Default ggplot theme
theme_set(theme_bw())

# Sets global options for running R2jags (available with the latest version --- my PR)
# No progress bar
options(r2j.pb="none")
# Run quietly
options(r2j.quiet=TRUE)
# Don't add the name of the program running MCMC as it spans the print table too widly
options(r2j.print.program=FALSE)

# Sets default fonts for tikz
library(tikzDevice)
options(tikzLatexPackages=c(
  getOption("tikzLatexPackages"),"\\usepackage{inconsolata,}",
  "\\usepackage[scaled=.89]{helvet}\n\\renewcommand{\\familydefault}{\\sfdefault}\n")
)
options(tikzMetricPackages = c(
  "\\usepackage[utf8]{inputenc}","\\usepackage[T1]{fontenc}", "\\usetikzlibrary{calc}", "\\usepackage{amssymb}")
)

# Trick to automatically convert pdf graphs generated with dev='tikz' into png so they work in html format
# see: https://github.com/rstudio/bookdown/issues/275
# NB: This version also fixes the issue with tikz leaving pdf files around and not saving the png into
#     the xxx_files/figure-revealjs/ folder
knitr::opts_hooks$set(dev = function(options) {
  if (identical(options$dev, 'tikz') && !knitr:::is_latex_output()) {
    options$fig.process = function(x) {
      if (!grepl('[.]pdf$', x)) return(x)  
      fig_dir <- knitr::opts_chunk$get("fig.path")
      if (is.null(fig_dir)) fig_dir <- "figure/"
      fig_dir <- sub("/+$", "", fig_dir)    
      # Use here::here() to get the absolute path for the figure directory
      output_dir <- here::here()  # Project root
      full_fig_dir <- file.path(output_dir, fig_dir)
      dir.create(full_fig_dir, recursive = TRUE, showWarnings = FALSE)
      # Output file name
      x2name <- sub('pdf$', 'png', basename(x))
      x2 <- file.path(full_fig_dir, x2name) 
      # Convert and save
      magick::image_write(magick::image_read(x, density = 300), x2, format = 'png', quality = 100)
      # Clean up the original PDF
      file.remove(x)# Return RELATIVE path so HTML can reference it
      file.path(fig_dir, x2name)
    }
  }
  options
})

#' This makes the fonts play nicely within the figures
#' (but uses a weird font, not Arial, so can be turned off)
# knitr::opts_chunk$set(dev = "ragg_png")
# This sets up the overall options for computation output
knitr::opts_chunk$set(
  fig.width = 12, fig.height = 9, out.width = "55%", fig.align = "center"
)

