
# ensure version is correct, then:
# run line by line (some commands require command line input)
rhc <- rhub::check_for_cran(show_status = FALSE)
devtools::check_win_devel()
devtools::check_win_release()
devtools::check()
devtools::spell_check()
revdepcheck::revdep_check()
# make sure you've put comments in cran-comments.md

# install the new version
# IF YOU WANT TO KEEP WEBSITE ON THE CRAN VERSION:
# do this on branch website-x.y.z. Then you can commit and push changes without
# devtools complaining about uncommitted changes.
# OTHERWISE, JUST DO THIS ON MASTER
pkgdown::build_site()


my_home <- "~/hughjonesd.github.io/"
rmarkdown::render("vignettes/tutorials/visual-introduction.Rmd",
      output_dir = my_home)
file.copy("vignettes/tutorials/chopping-dates-with-santoku.Rmd", my_home,
            overwrite = TRUE)
file.copy("vignettes/tutorials/figures", my_home, recursive = TRUE)
withr::with_dir(my_home,
  rmarkdown::render("chopping-dates-with-santoku.Rmd")
)
# but don't push yet! it affects what is seen from the website...
# NB you may need to update the README on master, as this is part
# of the package.

# Now back to master:
devtools::release()

# when it's accepted:
# - merge website-x.y.z into master
# - push hughjonesd.github.io
# - git tag -a cran-x.y.z
# - git push --tags