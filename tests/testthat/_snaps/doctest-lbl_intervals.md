# Example: lbl_intervals

    Code
      tab(-10:10, c(-3, 0, 0, 3), labels = lbl_intervals())
    Output
      [-10, -3)   [-3, 0)       {0}    (0, 3)   [3, 10] 
              7         3         1         2         8 

---

    Code
      tab_evenly(runif(20), 10, labels = lbl_intervals(fmt = percent))
    Output
      [11.75%, 20.36%) [20.36%, 28.96%) [37.57%, 46.18%) [46.18%, 54.79%) 
                     2                2                1                3 
      [54.79%, 63.39%)    [63.39%, 72%)    [72%, 80.61%) [80.61%, 89.22%) 
                     1                4                1                1 
      [89.22%, 97.82%] 
                     5 

