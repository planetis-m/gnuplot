import std / [osproc, os, streams, strutils]

type
  Figure = object
    content: string
    idNum: int
    replot: bool

proc `=destroy`*(fig: var Figure)

var
  nextIdNum = 0
  currentFigure: Figure

let gnuplotExe = findExe("gnuplot")

proc getCurrentFigure*(): var Figure =
  assert(currentFigure.idNum != 0, "Initialize a new global Figure with startGnuplot")
  currentFigure

proc setCurrentFigure*(fig: sink Figure) =
  assert(currentFigure.idNum == 0, "Global gnuplot Figure already instantiated")
  currentFigure = fig

proc cmd*(cmd: string; fig: var Figure = getCurrentFigure()) =
  ## Send a command to gnuplot
  when defined(debugGnuplot): echo "Figure id: ", fig.idNum, ", Contents:\n", cmd
  fig.content.add cmd
  fig.content.add "\n"

proc initFigure*(): Figure =
  ## Initiates a new Figure that communicates with gnuplot
  if gnuplotExe == "":
    raise newException(OSError, "Cannot find gnuplot: exe not in PATH")
  inc(nextIdNum)
  result = Figure(content: newStringOfCap(1_000), idNum: nextIdNum)
  cmd("load 'setup.gp'", result)

proc startGnuplot*() =
  ## Starts gnuplot in a global instance
  var fig = initFigure()
  setCurrentFigure(fig)

proc `=destroy`*(fig: var Figure) =
  ## close figure at the end of the session
  if fig.idNum != 0:
    cmd("exit", fig)
    ## Starts gnuplot
    let p = startProcess(gnuplotExe, args = ["-persist"])
    let inp = p.inputStream()
    inp.write(fig.content)
    inp.flush()

    `=destroy`(fig.content)
    discard p.waitForExit()
    if p.hasData():
      let outp = p.outputStream()
      let resp = outp.readAll()
      echo(resp)
    p.close()

proc plotCmd(replot: bool; fig: Figure): string =
  if replot and fig.replot:
    "replot "
  else:
    "plot "

template plotFunctionImpl(extra: typed) =
  var line = plotCmd(replot, fig) & equation & " " & extra
  if title != "":
    line.add " title '" & title & "' "
  cmd(line, fig)
  fig.replot = true

template plotDataImpl(extra: typed) =
  let
    title_line =
      if title == "": " notitle "
      else: " title '" & title & "' "
    line = plotCmd(replot, fig) & extra & title_line
  cmd(line, fig)
  fig.replot = true

proc plot*(equation: string; title, args = ""; replot = true;
    fig: var Figure = getCurrentFigure()) =
  ## Plot an equation as understood by gnuplot. e.g.:
  ##
  ## .. code-block:: nim
  ##   plot "sin(x)/x"
  plotFunctionImpl(args)

template fmt(x: string): string =
  x

template fmt(x: SomeFloat): string =
  formatFloat(x, ffDecimal, 6)

template fmt(x: untyped): string =
  $x

proc plot*[T](xs: openarray[T]; title, args = ""; replot = true;
    fig: var Figure = getCurrentFigure()) =
  ## plot an array or seq of float64 values. e.g.:
  ##
  ## .. code-block:: nim
  ##   import random, sequtils
  ##
  ##   let xs = newSeqWith(20, rand(1.0))
  ##
  ##   plot xs, "random values"
  cmd("$d << EOD", fig)
  for x in xs:
    cmd(fmt(x), fig)
  cmd("EOD", fig)
  plotDataImpl(" $d " & args)

proc plot*[X, Y](xs: openarray[X]; ys: openarray[Y];
    title, args = ""; replot = true; fig: var Figure = getCurrentFigure()) =
  ## plot points taking x and y values from corresponding pairs in
  ## the given arrays.
  ##
  ## With a bit of effort, this can be used to
  ## make date plots. e.g.:
  ##
  ## .. code-block:: nim
  ##   let
  ##     x = ["2014-01-29",
  ##          "2014-02-05",
  ##          "2014-03-15",
  ##          "2014-04-12",
  ##          "2014-05-24",
  ##          "2014-06-02",
  ##          "2014-07-07",
  ##          "2014-08-19",
  ##          "2014-09-04",
  ##          "2014-10-26",
  ##          "2014-11-21",
  ##          "2014-12-07"]
  ##     y = newSeqWith(len(x), rand(10.0))
  ##
  ##   cmd "set timefmt '%Y-%m-%d'"
  ##   cmd "set xdata time"
  ##
  ##   plot x, y, "somecoin value over time"
  ##
  ## or other drawings. e.g.:
  ##
  ## .. code-block:: nim
  ##   var
  ##     x = newSeq[float64](100)
  ##     y = newSeq[float64](100)
  ##
  ##   for i in 0..< 100:
  ##     let f = float64(i)
  ##     x[i] = f * sin(f)
  ##     y[i] = f * cos(f)
  ##
  ##   plot x, y, "spiral"
  assert(xs.len == ys.len, "xs and ys must have the same length")
  cmd("$d << EOD", fig)
  for i in 0 .. high(xs):
    cmd(fmt(xs[i]) & " " & fmt(ys[i]), fig)
  cmd("EOD", fig)
  plotDataImpl(" $d using 1:2 " & args)

proc pdf*(filename = "tmp.pdf"; width = 16.9; height = 12.7;
    fig: var Figure = getCurrentFigure()) =
  ## script to make gnuplot print into a pdf file
  ## Size is given in cm.
  ## In order to change the font edit gnuplot variable my_font in style_template.
  ##
  ## .. code-block:: nim
  ##   pdf(filename="myFigure.pdf")  # overwrites/creates myFigure.pdf
  cmd("my_export_sz = '" & $width & "," & $height & "'", fig)
  cmd("cmd = exportPdf('" & filename & "')", fig)
  cmd("@cmd", fig)

proc png*(filename = "tmp.png", width = 640, height = 480;
    fig: var Figure = getCurrentFigure()) =
  ## script to make gnuplot print into a png file
  ## Size is given in pixels.
  ## In order to change the font edit gnuplot variable my_font in style_template.
  ##
  ## .. code-block:: nim
  ##   pdf(filename="myFigure.png")  # overwrites/creates myFigure.png
  cmd("my_export_sz = '" & $width & "," & $height & "'", fig)
  cmd("cmd = exportPdf('" & filename & "')", fig)
  cmd("@cmd", fig)
