#' Uses R to create HTML code to make space
#'
#' @param space The amount of vertical space to include (default to "-20px")
#'
vspace=function(space="-20px") {
  paste('<span style="display:block; margin-top:',space,';"></span>')
}

#' Creates a 'tab' function that adds horizontal space(s)
#'
#' @param x The number of 'tabs' to be added (defaults to 1)
#'
tab=function(x=1) {
  cat(rep("&nbsp;",x),sep="")
}

#' Defines a LaTeX macro to typeset text using the default font
#' (as for the rest of the text in the slides)
#'
#' @param x The text of string to be inserted in the LaTeX equation. Can also
#' use xaringan colors for equations, eg '.red[$$x^2$$]'. If a color is not
#' named (but defined in the .css file), need to use the MathJax command
#' \code{\\class}, eg \code{$\\class{color}{x^2}$}
#'
sftext=function(x) {
  paste0("\\style{font-family:inherit;}{\\text{",x,"}}")
}

#' Macro to include figures from file
#'
#' @param img The string with the name of the file with the image to be included
#' @param dir The path to the image. By default, assumes that the images to be
#' loaded are in the \code{img} folder under the current directory, ie where the
#' current Rmd presentation is stored. But a full directory can be passed on
#' @param width The width of the image (default 100\%)
#' @param title The string of text to define the alt tag for the image
#'
include_fig=function(img,dir="./img",width="100%",title="INCLUDE TEXT HERE") {
  filename=file.path(dir,img)
  paste0("<center><img src=",filename," width='",width,"' title='",title,"'></center>")
}

#' Adds social media icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param social The name of the social media icon to add (a 'fontawesome' icon)
#' @param url The URL of the Twitter account
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Follow me on Twitter')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_social=function(social,url,title,fill="#bcc0c4",scale=".8em",style="border-bottom: 0px!important;") {
  icon=paste0('fontawesome::fa("',social,'",height=scale,fill=fill)')
  paste0('&nbsp;<a style="',style,'" href="',url,'" title="',title,'">',eval(parse(text=icon)),'</a>&nbsp;')
}

#' Adds twitter icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the Twitter account
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Follow me on Twitter')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;',style=NULL)
#'
add_twitter=function(url="https://twitter.com/giabaio",title="Follow me on Twitter",fill="#bcc0c4",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("twitter",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds X (FKA Twitter) icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the X account
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Follow me on X')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;',style=NULL)
#'
add_x=function(url="https://twitter.com/giabaio",title="Follow me on X",fill="#bcc0c4",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("x-twitter",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds mastodon icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the Twitter account
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Follow me on Mastodon')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_mastodon=function(url="https://mas.to/@gianlubaio",title="Follow me on Mastodon",fill="#bcc0c4",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("mastodon",fill=fill,height=scale),'</a>&nbsp;')
}


#' Adds email icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param email The email address
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Email me')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_email=function(email="g.baio@ucl.ac.uk",title="Email me",fill="#bcc0c4",scale="0.8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="mailto:',email,'" title="',title,'">',fontawesome::fa("envelope",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds website icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the website
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Visit my website')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_website=function(url="https://gianluca.statistica.it",title="Visit my website",fill="#bcc0c4",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("firefox",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds github icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the website
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Check out my repos')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_github=function(url="https://github.com/giabaio",title="Check out my repos",fill="#bcc0c4",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("github",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds linkedin icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the website
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Follow me on LinkedIn')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_linkedin=function(url="https://www.linkedin.com/in/gianluca-baio-b893879/",title="Follow me on LinkedIn",fill="#2867b2",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("linkedin",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds instagram icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the website
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Follow us on Instagram')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_instagram=function(url="https://www.instagram.com/ucl.stats/",title="Follow us on Instagram",fill="#2867b2",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("instagram",fill=fill,height=scale),'</a>&nbsp;')
}

#' Adds podcast icon & link (to be used, eg in the 'footer-social' container)
#'
#' @param url The URL of the website
#' @param title The alt text to be shown upon hovering the icon (default at
#' 'Random Talks')
#' @param fill A string or a HEX code with the color of the icon
#' @param scale A number indicating the scale of the icon (default = 0.8)
#' @param style A string with some css style options (e.g. 'border-bottom: 0px;')
#'
add_podcast=function(url="https://soundcloud.com/uclsound/sets/sample-space",title="Random Talks",fill="#FE5000",scale=".8em",style=NULL) {
  paste0('&nbsp;<a style="',style,';" href="',url,'" title="',title,'">',fontawesome::fa("soundcloud",fill=fill,height=scale),'</a>&nbsp;')
}

#' Makes css/html code to create post-its with variable inputs
#'
#' @param text The text to be printed
#' @param top The position from the top of the slide (default "50\%")
#' @param left The position from the left of the slide (default "2.5\%")
#' @param fontsize The font size for the text (default as "85\%" of normal size)
#' @param height The height of the enclosing post it (default at "4em")
#' @param width The width of the enclosing post it (default at "4em")
#' @param rotate The rotation for the post it (default at "6deg")
#'
postit=function(text="This is some text",top="50%",left="2.5%",fontsize="85%",height="4em",width="4em",rotate="6deg") {
  paste0(
    '<p style="position: absolute; top:',top,'; left:',left,'; font-family: Nanum Pen Script; font-size:',fontsize,
    '; text-decoration: none; color: #000; background: #ffc; display: block; height:',height,'; width:',width,
    '; padding: .5em; box-shadow: 5px 5px 7px rgba(33,33,33,.7); transform: rotate(',rotate,'); border-bottom-right-radius: 60px 5px;">',text,'</p>'
  )
}

# Creates HTML code to include the samptux icon + link to gianluca.statistica.it
samptux=function(path="assets/logo.png",width="2.0%",text="") {
  paste0('<span><a href="https://gianluca.statistica.it/"><img src="',path,'" title="Go home" width="',width,'"></a>',text,'</span>')
  # But could use other links/icons, eg
  #<p><a href="https://gianluca.statistica.it/"><i class="fas fa-home" title="Go home" style="color: #bcc0c4;"></i></a></p>
  # Also, could use the 'xaringanExtra::use_logo()' function as well (which does pretty much the same thing...)
}

twitter=function(alt="") {
  icon="assets/images/twitter.png"
  link="https://twitter.com/gianlubaio"
  htmltools::tags$a(.noWS = c("after-begin", "before-end"),
                    href = link,
                    htmltools::tags$img(src = icon, alt = alt, width = "32", height = "32", style = "border: none;")
  )
}
linkedin=function(alt="") {
  icon="images/linkedin.png"
  link="https://www.linkedin.com/in/gianluca-baio-b893879/"
  htmltools::tags$a(.noWS = c("after-begin", "before-end"),
                    href = link,
                    htmltools::tags$img(src = icon, alt = alt, width = "32", height = "32", style = "border: none;")
  )
}
github=function(alt="") {
  icon="images/github.png"
  link="https://www.github.com/giabaio"
  htmltools::tags$a(.noWS = c("after-begin", "before-end"),
                    href = link,
                    htmltools::tags$img(src = icon, alt = alt, width = "32", height = "32", style = "border: none;")
  )
}
scholar=function(alt="") {
  icon="images/scholar.png"
  link="https://scholar.google.com/citations?user=ro0QvGsAAAAJ&hl=en"
  htmltools::tags$a(.noWS = c("after-begin", "before-end"),
                    href = link,
                    htmltools::tags$img(src = icon, alt = alt, width = "32", height = "32", style = "border: none;")
  )
}
researchgate=function(alt="") {
  icon="images/researchgate.png"
  link="https://www.researchgate.net/profile/Gianluca_Baio"
  htmltools::tags$a(.noWS = c("after-begin", "before-end"),
                    href = link,
                    htmltools::tags$img(src = icon, alt = alt, width = "32", height = "32", style = "border: none;")
  )
}

#' Creates html code to include the UCL Stats logo on the title slide of a
#' quarto presentation. Needs to do this because quarto messes up with the
#' path of the main theme css, so cannot include the logo using the css code
#'
#' @param url The path to the file
#'
logo_stats=function(url="assets/images/UCL_Stats_logo.jpeg"){
  paste0(
    "<p style='position: absolute; top: 86.0%; left: 92.0%; text-decoration:none; display:block;
    height: 3.5em; width: 3.5em; padding: .5em; box-shadow: 5px 5px 7px rgba(33,33,33,.7);
    background-image: url(\"",url,"\"); background-size: contain; border-radius: 6px 6px 6px 6px;'></p>"
  )
}


#' Create Quarto slides using GB predefined template (similar to the
#' `xaringan` one). This function is based heavily on Cara Thompson's
#' package `samplespace` developed specifically for UCL Stats Science
#'
#' @param file_name The file name for your .qmd file (with or without ".qmd" at
#' the end; the function takes care of that to avoid needing to remember
#' whether to include it or not!)
#' @param style Defaults to `gb`, but could create more, in the vain of the
#' `samplespace` package
#' @param directory The directory where the files should be created.
#' Defaults to `here::here("slides")`
quarto_slides=function(file_name,style="gb",directory=here::here("slides")) {
  file_name <- gsub(".qmd", "", file_name, fixed = TRUE)
  if (!dir.exists(directory)) {
    dir.create(directory)
  }
  if (file.exists(here::here(directory, paste0(file_name, ".qmd")))) {
    stop("*** ", here::here(directory, paste0(file_name,
                                              ".qmd")), " already exists! ***\n          \nI won't overwrite your existing file. \nPlease choose a different directory or file name for your new slides (or delete/rename the existing file). ")
  }
  else {
    string_to_swap <- system.file("quarto/", package = "slides")
    if (style == "gb") {
      footer_file <- grep(
        "quarto-support/footer.css",
        list.files(
          system.file(
            "quarto/gb-slides_files/libs",package = "slides"
          ), recursive = TRUE,full.names = TRUE
        ), value = TRUE
      )
      header_logo_file <- grep(
        "libs/revealjs/dist/theme/images",
        list.files(
          system.file(
            "quarto/gb-slides_files/libs/revealjs/dist/theme/images",
            package = "slides"
          ), recursive = TRUE,
          full.names = TRUE
        ), value = TRUE
      )
      files_to_copy <- grep(
        ".qmd|.scss|title-slide.html",
        grep(
          "gb|title-slide",
          list.files(
            system.file("quarto",package = "slides"), recursive = FALSE,
            full.names = TRUE
        ), value = TRUE), value = TRUE
      )
      file.copy(from = files_to_copy, to = gsub(string_to_swap,
                                                directory, files_to_copy))
      if (!dir.exists(file.path(directory, paste0(file_name,
                                                  "_files"), "libs", "revealjs", "plugin", "quarto-support"))) {
        dir.create(file.path(directory, paste0(file_name,
                                               "_files"), "libs", "revealjs", "plugin", "quarto-support"),
                   recursive = TRUE)
      }
      if (
        !dir.exists(
          file.path(
            directory,
            paste0(file_name,"_files"), "libs", "revealjs", "dist", "theme","images"
          )
        )
      ) {
        dir.create(
          file.path(
            directory, paste0(file_name,"_files"), "libs", "revealjs", "dist", "theme","images"
          ), recursive = TRUE
        )
      }
      file.copy(
        from = system.file(
          "quarto/gb-slides_files/libs/revealjs/dist/theme/images/UCL_Stats_logo.jpeg",
          package = "slides"
        ),
        to = gsub(
          string_to_swap,directory,
          gsub(
            "gb-slides", file_name,
            system.file(
              "quarto/gb-slides_files/libs/revealjs/dist/theme/images/UCL_Stats_logo.jpeg",
              package = "slides"
            )
          )
        )
      )
      file.copy(
        from = system.file(
          "quarto/gb-slides_files/libs/revealjs/dist/theme/images/UCL-stats.png",
          package = "slides"
        ),
        to = gsub(
          string_to_swap,directory,
          gsub(
            "gb-slides", file_name,
            system.file(
              "quarto/gb-slides_files/libs/revealjs/dist/theme/images/UCL-stats.png",
              package = "slides"
            )
          )
        )
      )
      file.copy(
        from = footer_file,
        to = gsub(
          string_to_swap,directory, gsub(
            "gb-slides_files", paste0(file_name,"_files"), footer_file
          )
        )
      )
      file.rename(here::here(directory, "gb-slides.qmd"),
                  here::here(directory, paste0(file_name, ".qmd")))
    }
    # Can add different styles here...
#    else if (style == "samplespace") {
#      footer_file <- grep("quarto-support/footer.css",
#                          list.files(system.file("quarto/samplespace-slides_files/libs/",
#                                                 package = "samplespace"), recursive = TRUE,
#                                     full.names = TRUE), value = TRUE)
#      files_to_copy <- grep(".qmd|.scss|title-slide.html",
#                            grep("quarto/samplespace|title-slide", list.files(system.file("quarto/",
#                                                                                          package = "samplespace"), recursive = FALSE,
#                                                                              full.names = TRUE), value = TRUE), value = TRUE)
#      file.copy(from = files_to_copy, to = gsub(string_to_swap,
#                                                directory, files_to_copy))
#      if (!dir.exists(file.path(directory, paste0(file_name,
#                                                  "_files"), "libs", "revealjs", "plugin", "quarto-support"))) {
#        dir.create(file.path(directory, paste0(file_name,
#                                               "_files"), "libs", "revealjs", "plugin", "quarto-support"),
#                   recursive = TRUE)
#      }
#      file.copy(from = footer_file, to = gsub(string_to_swap,
#                                              directory, gsub("samplespace-slides_files", paste0(file_name,
#                                                                                                 "_files"), footer_file)))
#      file.rename(here::here(directory, "samplespace-slides.qmd"),
#                  here::here(directory, paste0(file_name, ".qmd")))
#    }
    else {
      stop(message = "I don't recognise that style of slides. Please choose \"gb\" or something else that exists. Thank you!")
    }
    if (!dir.exists(file.path(directory, "images"))) {
      dir.create(file.path(directory, "images"))
    }
    if (!dir.exists(file.path(directory, "_extensions"))) {
      dir.create(file.path(directory, "_extensions"))
    }
    if (!dir.exists(file.path(directory, "_extensions", "quarto-ext",
                              "lightbox"))) {
      dir.create(file.path(directory, "_extensions", "quarto-ext",
                           "lightbox"), recursive = TRUE)
    }
    if (!dir.exists(file.path(directory, "_extensions", "jjallaire",
                              "code-visibility"))) {
      dir.create(file.path(directory, "_extensions", "jjallaire",
                           "code-visibility"), recursive = TRUE)
    }
    image_files <- list.files(system.file("quarto/./images",
                                          package = "slides"), recursive = TRUE, full.names = TRUE)
    file.copy(from = image_files, to = gsub(string_to_swap,
                                            directory, image_files))
    file.copy(from = system.file("quarto/./_extensions",
                                 package = "slides"), to = directory, recursive = TRUE)
  }
}
