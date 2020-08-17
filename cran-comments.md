
A new version with an incremental improvement to the interface.



## Test environments

* local OS X install, R 4.0.2
* Ubuntu (on travis), R 4.0.0
* windows (on appveyor), R 4.0.2-patched
* win-builder (devel and release)
* rhub (using rhub::check_for_cran())

## R CMD check results

* 0/0/0 on OS X
* 0/0/0 on travis
* 0/0/0 on appveyor
* 0 notes on win-builder 
* 1 failed test on rhub linux, probably a result of floating point arithmetic, 
  not something one can fix.
