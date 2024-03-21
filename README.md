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

