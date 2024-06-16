# tbar works

    Code
      tbar(x)
    Output
       a ▉  [1]
       b ▉  [1]
       c ▉▉▉  [3]

---

    Code
      tbar(table(x))
    Output
       a ▉  [1]
       b ▉  [1]
       c ▉▉▉  [3]

---

    Code
      tbar(proportions(table(x)))
    Output
       a ▉▉▉▉▉▉▉▉▉▉▉▉  [0.2]
       b ▉▉▉▉▉▉▉▉▉▉▉▉  [0.2]
       c ▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉▉  [0.6]

---

    Code
      tbar(proportions(table(x)), width = 15)
    Output
       a ▉▉▉  [0.2]
       b ▉▉▉  [0.2]
       c ▉▉▉▉▉▉▉▉▉  [0.6]

---

    Code
      tbar(x, useNA = "always")
    Output
       a  ▉  [1]
       b  ▉  [1]
       c  ▉▉▉  [3]
       NA   [0]

