
# run line by line (some commands require command line input)
# make sure you've put comments in cran-comments.md
rhc <- rhub::check_for_cran(show_status = FALSE)
devtools::check_win_devel()
devtools::check_win_release()
devtools::check()
devtools::spell_check()
pkgdown::build_site()


my_home <- "~/hughjonesd.github.io/"
rmarkdown::render("vignettes/tutorials/visual-introduction.Rmd",
      output_dir = my_home)
file.copy("vignettes/tutorials/chopping-dates-with-santoku.Rmd", my_home,
      recursive = TRUE)
file.copy("vignettes/tutorials/figures", my_home)
withr::with_dir(my_home,
  rmarkdown::render("chopping-dates-with-santoku.Rmd")
)

devtools::release()
# push hughjonesd.github.io