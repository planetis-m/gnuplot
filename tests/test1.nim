import std / [unittest, random, sequtils], ".." / gnuplot

test "pdf":
  let
    x = [
      "2014-01-29",
      "2014-02-05",
      "2014-03-15",
      "2014-04-12",
      "2014-05-24",
      "2014-06-02",
      "2014-07-07",
      "2014-08-19",
      "2014-09-04",
      "2014-10-26",
      "2014-11-21",
      "2014-12-07"
    ]
    y = newSeqWith(len(x), rand(10.0))
  withGnuplot:
    cmd "set timefmt '%Y-%m-%d'"
    cmd "set xdata time"

    plot x, y, "somecoin value over time"
    pdf()

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
