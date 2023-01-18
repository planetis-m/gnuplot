import unittest

import gnuplot
test "png":
  withGnuplot:
    plot "sin(x)", title = "sin(x)", args = "with lines linestyle 2"
    plot "cos(x)", title = "cos(x)", args = "with lines linestyle 3"
    png()

test "multiple concurrent plots":
  var x, y1, y2: seq[int]
  for i in 0 .. 10:
    x.add i
    y1.add i * 2
    y2.add i * i
  withGnuplot:
    plot x, y1, "y = 2x"
    plot x, y2, "y = x^2"
    png()
