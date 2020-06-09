
# run line by line (some commands require command line input)
# make sure you've put comments in cran-comments.md
rhc <- rhub::check_for_cran(show_status = FALSE)
devtools::check_win_devel()
devtools::check_win_release()
devtools::check()
devtools::spell_check()
pkgdown::build_site()
rmarkdown::render("vignettes/tutorials/visual-introduction.Rmd",
      output_dir = "~/hughjonesd.github.io/")
devtools::release()
# push hughjonesd.github.io