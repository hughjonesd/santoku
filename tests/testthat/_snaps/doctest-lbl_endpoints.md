# Example: lbl_endpoints

    Code
      chop(1:10, c(2, 5, 8), lbl_endpoints(left = TRUE))
    Output
       [1] 1 2 2 2 5 5 5 8 8 8
      Levels: 1 2 5 8

---

    Code
      chop(1:10, c(2, 5, 8), lbl_endpoints(left = FALSE))
    Output
       [1] 2  5  5  5  8  8  8  10 10 10
      Levels: 2 5 8 10

---

    Code
      tab_width(as.Date("2000-01-01") + 0:365, months(1), labels = lbl_endpoints(fmt = "%b"))
    Output
      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec 
       31  29  31  30  31  30  31  31  30  31  30  31 

