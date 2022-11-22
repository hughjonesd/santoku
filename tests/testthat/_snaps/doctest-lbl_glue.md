# Example: lbl_glue

    Code
      tab(1:10, c(1, 3, 3, 7), label = lbl_glue("{l} to {r}", single = "Exactly {l}"))
    Output
         1 to 3 Exactly 3    3 to 7   7 to 10 
              2         1         3         4 

---

    Code
      tab(1:10 * 1000, c(1, 3, 5, 7) * 1000, label = lbl_glue("{l}-{r}", fmt = function(
        x) prettyNum(x, big.mark = ",")))
    Output
       1,000-3,000  3,000-5,000  5,000-7,000 7,000-10,000 
                 2            2            2            4 

---

    Code
      tab(1:10, c(1, 3, 3, 7), label = lbl_glue(glue_string, single = "{{{l}}}"))
    Output
       [1, 3)     {3}  (3, 7) [7, 10] 
            2       1       3       4 

