This contains cosmetic changes in response to CRAN's initial review:

* Updated license year to 2020.
* Tweaked the Value sections in man pages of `exactly` and `knife`.
* Removed "for R" from DESCRIPTION.

## Test environments
* local OS X install, R 3.6.2
* ubuntu 14.04 (on travis-ci), R 3.6.2
* win-builder (devel and release)
* rhub (using rhub::check_for_cran())

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

In addition, one rhub platform gave the following note:

> checking for non-standard things in the check directory ... NOTE
  Found the following files/directories:
    'examples_i386' 'examples_x64' 'santoku-Ex_i386.Rout'
    'santoku-Ex_x64.Rout' 'tests_i386' 'tests_x64'
