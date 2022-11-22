# Example: lbl_dash

    Code
      chop(1:10, c(2, 5, 8), lbl_dash())
    Output
       [1] 1—2  2—5  2—5  2—5  5—8  5—8  5—8  8—10 8—10 8—10
      Levels: 1—2 2—5 5—8 8—10

---

    Code
      chop(1:10, c(2, 5, 8), lbl_dash(" to ", fmt = "%.1f"))
    Output
       [1] 1.0 to 2.0  2.0 to 5.0  2.0 to 5.0  2.0 to 5.0  5.0 to 8.0  5.0 to 8.0 
       [7] 5.0 to 8.0  8.0 to 10.0 8.0 to 10.0 8.0 to 10.0
      Levels: 1.0 to 2.0 2.0 to 5.0 5.0 to 8.0 8.0 to 10.0

---

    Code
      chop(1:10, c(2, 5, 8), lbl_dash(first = "<{r}"))
    Output
       [1] <2   2—5  2—5  2—5  5—8  5—8  5—8  8—10 8—10 8—10
      Levels: <2 2—5 5—8 8—10

---

    Code
      chop(runif(10) * 10000, c(3000, 7000), lbl_dash(" to ", fmt = pretty))
    Output
       [1] 7,000 to 9,889 824 to 3,000   7,000 to 9,889 7,000 to 9,889 824 to 3,000  
       [6] 3,000 to 7,000 3,000 to 7,000 7,000 to 9,889 3,000 to 7,000 7,000 to 9,889
      Levels: 824 to 3,000 3,000 to 7,000 7,000 to 9,889

