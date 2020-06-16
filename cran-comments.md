
Resubmitting with a one-liner documentation fix. Original comments below. I
have retested locally, on travis and appveyor, on win-builder (r-devel) and
on rhub for windows, but these did not catch the original bug.

--

This update fixes one serious bug.

## Test environments

* local OS X install, R 4.0.0
* Ubuntu (on travis), R 4.0.0
* windows (on appveyor), R 4.0.1-patched
* win-builder (devel and release)
* rhub (using rhub::check_for_cran())

## R CMD check results

* 0/0/0 on OS X
* 0/0/0 on travis
* 0/0/0 on appveyor
* 1 note (recent update) on win-builder 
* 1 irreproducible error on rhub, probably a glitch
  
