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
      # Process the image
      img <- magick::image_read(x, density = 300)
      # Can also make white transparent, by default...
      #      img <- magick::image_transparent(img, "white")
      # Convert and save
      magick::image_write(img, x2, format = 'png', quality = 100)
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
  fig.width = 7, fig.height = 5, out.width = "55%", fig.align = "center"
)

# Additional graphical instructions to add to the normal ./assets/setup.R *only* if the style chosen in ucl-revealjs
if (rmarkdown::metadata$format=="ucl-revealjs") {

  # UCL colour palette - official colour scaling
  ucl_palette = c(
    "#5487ff", #blue
    "#ed367d", #fucsia
    "#57b444", #teal green
    "#e36c2a", #orange
    "#005e5c", #dark green
    "#9e1a54", #dark fucsia
    "#781c1c", #dark orange
    "#002ea6"  #dark blue
  )

  # Specialised ggplot theme
  theme_ucl <- function(ignore_panel = TRUE) {
    th <- theme_bw() +
      theme(
        plot.background  = element_rect(fill = "#fafafa", colour = NA),
        legend.background = element_rect(fill = "#fafafa", colour = NA),
        legend.key = element_rect(fill = "#fafafa", colour = NA)
      )
    if (!ignore_panel) {
      th <- th + theme(panel.background = element_rect(fill = "#fafafa", colour = NA))
    }
    th
  }
  options(
    ggplot2.discrete.colour = ucl_palette,
    ggplot2.discrete.fill = ucl_palette
  )
  theme_set(theme_ucl(ignore_panel=rmarkdown::metadata$`img-bg`))

  # Removes background for base graphs
  knitr::opts_chunk$set(
    dev = "png",
    dev.args = list(bg = "#fafafa")
  )

  # Removes background for tikz images
  knitr::opts_hooks$set(engine = function(options) {
    if (identical(options$engine, "tikz") && !knitr:::is_latex_output()) {
      original_code <- options$code
      # Prepend pagecolor (or input your setup file)
      options$code <- c("\\pagecolor[HTML]{FAFAFA}", original_code)
    }
    options
  })
}
