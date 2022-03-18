
A new version with some breaking changes.


## Test environments

* local (macOS), R 4.1.0
* appveyor (windows), R 4.1.3-patched
* github (windows, macOS, Ubuntu), devel and release
* win-builder (windows), devel and release
* rhub (using rhub::check_for_cran())

## R CMD check results

* OK locally, on Appveyor and github.
* NOTES re Author: and Authors@R: on win-builder and rhub. 
  - Fixed by removing Author:


