# `slides` - an `R` package to create `quarto` and `xaringan` slides templates

This package is written initially to create templated `xaringan` slides. 

## `xaringan` slides
The first type of presentation templates created is using [`xaringan`](https://github.com/yihui/xaringan). This works really well and is quite flexible. It allows `LaTeX`-like notation (eg for mathematics) but outputs the slides onto `html` using `remark.js`. When the `slides` package is installed, then in `Rstudio` the slides appear as one of the templates. Click on `File` -> `New File` -> `R Markdown` and then select `From Template`. From there use the `UCL Presentation` template. It is also possible to select the folder in which the template is saved and a suitable `Rproj` created. Then can edit the templated slides and produce the relevant `html` presentation. This can be simply uploaded on a website for presentation and dissemination.

## `quarto`
More recently and building on the work of Cara Thompson (for the package `samplespace`, which contains UCL Stats Science-themed slides), a new template based on `quarto` and `reveal.js`. This is a bit more modern and, to some extent, more powerful. The template is very similar to the `xaringan` one --- differences are really minor. The way in which the slides are created is one and is based on the `slides` function `quarto_slides`. This takes as inputs the name of the file and the folder into which the presentation is to be saved.
```
slides::quarto_slides(
   file_name="index",
   directory="myslides"
)
```

### Settings for the `quarto` slides
The `yml` for the slides `qmd` file contains a few different blocks.

1. Dynamic attributes. 
These are the data that define the specific presentation such as: 
   - `title` 
   - `subtitle` (default at `""`; if present goes under the main title)
   - `shorttitle` (the text that goes into the footer) 
   - `date` (if `""` then today's date gets parsed and included in the title slides and in the footer)
   - `conference` (a multi-item field, including details of the `name` of the conference, the `location` of the conference and the name of the `session`. Either of these can be left empty)
   - `shortconference` (a string with a shorter version of the conference name to go into the footer)
   - `postit` (a multi-item field with values `random-talks` and `social-media`; if either is set to `true`, then the post-it is included in the title page)
   - `slidesurl` (a multi-item field with values `show` and `url`, a link to the page at which the slides are hosted/available. If `show: false`, then nothing appears in the footer)
   - `thank-you` (a multi-item field with values `show` and the name of the `file` containing the thank-you `gif`. If `show` is `true` then shows the thank-you slide at the end of the presentation, according to the value of `file`, whose options are `reese`, `phoebe` and `joey` --- can add as many as needed...)
   - `bibliography` (the full path to the file containing the `bib` file with the references to be used, if needed)
   
2. (Semi-)Fixed attributes (these don't *need* to, but can be changed)
   - `author` (a multi-item field, possibly with multiple `author` values, to show in the title slide)
   - `institute` (a multi-item field, including by default the value `uni` with department and institution, to show in the title slide)
   - `email` (a multi-item field with the `text` for the URL of the email and the `icon`, using fontawesome)
   - `url` (a multi-item field, containing multiple values such as `text`, the actual URL of the webpage to show in the title slide and `icon`, using fontawesome)
   - `github` (a multi-item field, containing multiple values such as `text`, the actual URL of the GitHub repo to show in the title slide and `icon`, using fontawesome)
   - `social` (a multi-item field, containing multiple values such as `text`, the actual link to the social media channel to show in the title slide and `icon`, using fontawesome)
   - `orchid` (a multi-item field, containing multiple values such as `show`, which defaults to `false`, `url`, the actual link to the ORCHID page, to show in the title slide and `icon`, using fontawesome)
   - `date-format` (the `quarto` command to format the way in which the date should appear)
   
3. Computed attributes (from other parts of the yml file)
   - These are `R` code used to create variable using the dynamic information provided in the `yml` to be then passed to other parts of the `yml`, eg to create the footer
   
The rest of the `yml` defines the format of the `revealjs` slide. The title page can be modified by changing the template in `assets/title-page.html`. The appearance of the actual slides can also be modified by adding the code 
```
- template: "assets/template.html"
```
where the file `assets/template.html` is added (from [here](https://github.com/quarto-dev/quarto-cli/blob/main/src/resources/formats/revealjs/pandoc/template.html)) and modified as required.

In addition, **for the UCL** theme only, the slides can be rendered using either `revealjs` (to `html`) or `beamer` (to `pdf`). This is controlled by the input
```
#' Format. Here selects the style of the slides; other choices are 'gb-revealjs' or 'sampdoria-revealjs'
format: 
  ucl-XXX
```
where `XXX` is either `revealjs` or `beamer`. The `_extensions` folder contains a number of subfolders, each defining a specific theme: 

- `gb` (old UCL template)
- `sampdoria` (a theme based on the Sampdoria palette)
- `ucl` (current UCL theme).

The folder `ucl` contains a further subfolder `beamer`, in which the `beamer` theme is coded up in the `ucl-template.tex` file. There are also a number of `.lua` filters that can be used to aid `pandoc` processing through LaTeX.

## Printing the `html` slides

The `revealjs` slides can be printed to pdf more efficiently using `decktape`. It's possible to use the default pathway from `quarto` (press `e` then print to pdf),
but this may not handle title page background or some formulae very well.

`decktape` is installed with
```
npm install -g decktape
```
and then can be used with command line such as
```
decktape reveal --size 1600x900 \
  "https://gianluca.statistica.it/slides/presentation/" \
  presentation.pdf
```

Useful flags include:
- `--size 1600x900` matches Quarto's default reveal width/height
- `--slides 1-30` if you want a range
- `--pause 1500` gives `MathJax` more time before each screenshot (bump this if any equation looks half-rendered)
- `--fragments true` renders each fragment step as its own page

NB: to use some of these, it may be helpful to use explicitly the command `decktape reval` not just `decktape`.

This command can also be scripted, for instance as
```
#!/usr/bin/env bash
# render-pdf.sh
URL=${1:-"http://localhost:4321"}
OUT=${2:-"slides.pdf"}
decktape reveal --size 1600x900 --pause 1500 "$URL" "$OUT"
```
to make the pdf files. It may fail with sites hosted on `netflify`, as it doesn't want to give access to the 
`xxx_files` folder. In that case, just do the local render.

For password protected sites can do
```
decktape https://user:password@site.com --options
```
