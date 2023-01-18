import unittest

import gnuplot
test "png":
  withGnuplot:
    plot "sin(x)", title = "sin(x)", args = "with lines linestyle 2"
    plot "cos(x)", title = "cos(x)", args = "with lines linestyle 3"
    png()
