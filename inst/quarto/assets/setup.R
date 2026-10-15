#########################################
# Set up and common commands & packages #
#########################################
# Default ggplot theme
theme_set(theme_bw())

# Sets global options for running R2jags (available with the latest version --- my PR)
options(
  # No progress bar
  r2j.pb="none",
  # Run quietly
  r2j.quiet=TRUE,
  # Don't add the name of the program running MCMC as it spans the print table too widly
  r2j.print.program=FALSE
)

# Sets default fonts for tikz
library(tikzDevice)

options(
  tikzLatexPackages=c(
    getOption("tikzLatexPackages"),
    "\\usepackage{inconsolata}",
    "\\usepackage{amsmath}",
    "\\usepackage[scaled=.89]{helvet}\n\\renewcommand{\\familydefault}{\\sfdefault}\n"
  ),
  tikzMetricPackages=c(
    "\\usepackage[utf8]{inputenc}",
    "\\usepackage[T1]{fontenc}",
    "\\usetikzlibrary{calc}",
    "\\usepackage{amssymb}"
  )
)

# Trick to automatically convert pdf graphs generated with dev='tikz' into png so they work in html format
# see: https://github.com/rstudio/bookdown/issues/275
# NB: This version also fixes the issue with tikz leaving pdf files around and not saving the png into
#     the xxx_files/figure-revealjs/ folder
knitr::opts_hooks$set(dev=function(options) {
  if (identical(options$dev,"tikz") && !knitr::is_latex_output()) {
    options$fig.process=function(x) {
      if (!grepl("[.]pdf$",x)) return(x)
      fig_dir=knitr::opts_chunk$get("fig.path")
      if (is.null(fig_dir)) fig_dir="figure/"
      fig_dir=sub("/+$","",fig_dir)
      # Use here::here() to get the absolute path for the figure directory (project root)
      full_fig_dir=file.path(here::here(),fig_dir)
      dir.create(full_fig_dir,recursive=TRUE,showWarnings=FALSE)
      # Output file name
      x2name=sub("pdf$","png",basename(x))
      x2=file.path(full_fig_dir,x2name)
      # Process the image
      img=magick::image_read(x,density=300)
      # Can also make white transparent, by default...
      # img=magick::image_transparent(img,"white")
      # Convert and save
      magick::image_write(img,x2,format="png",quality=100)
      # Clean up the original PDF
      file.remove(x)
      # Return RELATIVE path so HTML can reference it
      file.path(fig_dir,x2name)
    }
  }
  options
})

#' This makes the fonts play nicely within the figures
#' (but uses a weird font, not Arial, so can be turned off)
# knitr::opts_chunk$set(dev="ragg_png")
# This sets up the overall options for computation output
knitr::opts_chunk$set(
  fig.width=7,fig.height=5,out.width="55%",fig.align="center"
)

# Additional graphical instructions to add to the normal ./assets/setup.R *only* if the style chosen in ucl-revealjs
# NB: 'format' can be a string or a nested list (if format options are specified), so check both
fmt=rmarkdown::metadata$format
if (is.list(fmt)) fmt=names(fmt)
if (any(fmt %in% c("ucl-revealjs","ucl-beamer"))) {
  
  # The palette.* theme elements only exist from ggplot2 4.0.0
  if (utils::packageVersion("ggplot2")<"4.0.0") {
    stop("The UCL theme needs ggplot2 >= 4.0.0")
  }
  
  # UCL colour palette - official colour scaling
  ucl_palette=c(
    uclblue="#5487ff", #blue
    uclred="#ed367d", #fucsia
    uclgreen="#57b444", #teal green
    uclorange="#e36c2a", #orange
    ucldarkgreen="#005e5c", #dark green
    ucldarkred="#9e1a54", #dark fucsia
    ucldarkorange="#781c1c", #dark orange
    ucldarkblue="#002ea6"  #dark blue
  )
  
  # Discrete palette: UCL colours, falls back to ggplot default hue if too many levels
  ucl_pal=function(n) {
    if (n<=length(ucl_palette)) {
      unname(ucl_palette[seq_len(n)])
    } else {
      scales::pal_hue()(n)
    }
  }
  
  # Specialised ggplot theme (also carries the palettes)
  theme_ucl=function(ignore_panel=TRUE,legend_pos=NULL) {
    # Determine legend background fill based on position
    leg_fill=if (identical(legend_pos,"inside")) "transparent" else "#fafafa"
    
    th=theme_bw() +
      theme(
        plot.background=element_rect(fill="#fafafa",colour=NA),
        legend.background=element_rect(fill=leg_fill,colour=NA),
        legend.key=element_rect(fill="#fafafa",colour=NA),
        palette.colour.discrete=ucl_pal,
        palette.fill.discrete=ucl_pal,
        palette.colour.continuous=c("#5487ff","#002ea6"),
        palette.fill.continuous=c("#5487ff","#002ea6")
      )
    
    if (!ignore_panel) {
      th=th + theme(panel.background=element_rect(fill="#fafafa",colour=NA))
    }
    
    if (!is.null(legend_pos)) {
      th=th + theme(legend.position=legend_pos)
    }
    
    th
  }
  
  # Make it the default for every plot
  # NB: isFALSE means a missing 'img-bg' in the YAML defaults to ignore_panel=TRUE (rather than crashing)
  theme_set(theme_ucl(ignore_panel=!isFALSE(rmarkdown::metadata$`img-bg`)))
  
  # Ordered factors: not covered by the theme palettes (as far as I know), so use the (undocumented) options
  options(
    ggplot2.ordinal.colour=function(...) scale_colour_discrete(palette=ucl_pal,...),
    ggplot2.ordinal.fill=function(...) scale_fill_discrete(palette=ucl_pal,...)
  )
  
  # Removes background for base graphs
  knitr::opts_chunk$set(
    dev="png",
    dev.args=list(bg="#fafafa")
  )
  
  # Removes background for tikz images
  knitr::opts_hooks$set(engine=function(options) {
    if (identical(options$engine,"tikz") && !knitr::is_latex_output()) {
      # Prepend pagecolor (or input your setup file)
      options$code=c("\\pagecolor[HTML]{FAFAFA}",options$code)
    }
    options
  })
}
