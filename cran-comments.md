
Some bugfixes and new features.

## Test environments

* local (macOS), R 4.3.1
* github (windows, macOS, Ubuntu), devel and release
* win-builder (windows), devel and release
* mac-builder release
* r-hub (windows), devel

## R CMD check results

* One NOTE about S3 methods shown with full name. These are methods which
  are also generics (using two levels of S3 methods). The documentation is
  marked as internal.
* One NOTE on win-builder about an invalid URL with "connection reset". 
  Probably a temp failure.

## Reverse dependencies

* None.
