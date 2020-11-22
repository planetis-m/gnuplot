import std / [os, osproc, streams, strutils, exitprocs]

var
  currentProc: Process
  backgroundThread: Thread[Process]
  hasPlotted: bool

proc getCurrentProc(): Process =
  assert(currentProc != nil, "Initialize a new global Process with startGnuplot")
  currentProc

proc setCurrentProc(p: Process) =
  assert(currentProc == nil, "Global gnuplot Process already instantiated")
  currentProc = p

proc cmd*(cmd: string) =
  ## Send a command to gnuplot
  when defined(debugGnuplot): echo cmd
  let p = getCurrentProc()
  try:
    let inp = p.inputStream()
    inp.writeLine(cmd)
    inp.flush()
  except:
    stdout.write("Error: Couldn't send command to gnuplot\n")
    quit(QuitFailure)

proc watchOutput(p: Process) {.thread.} =
  let outp = p.outputStream()
  while p.running() and not outp.atEnd():
    let line = outp.readLine()
    stdout.writeLine(line)

proc startGnuplot*() =
  ## Starts gnuplot in a global instance
  let gnuplotExe = findExe("gnuplot")
  if gnuplotExe == "":
    raise newException(OSError, "Cannot find gnuplot: exe not in PATH")
  let path = currentSourcePath.parentDir()
  let p = startProcess(gnuplotExe, path, ["--persist"], options = {poStdErrToStdOut, poUsePath, poDaemon})
  setCurrentProc(p)
  createThread(backgroundThread, watchOutput, p)
  cmd("load 'setup.gp'")

proc closeGnuplot() {.noconv.} =
  ## close Process at the end of the session
  let p = getCurrentProc()
  cmd("exit")
  try:
    discard p.waitForExit()
    p.close()
  except:
    discard

proc plotCmd(replot: bool): string =
  result = if replot and hasPlotted: "replot " else: "plot "

template plotFunctionImpl(extra: typed) =
  var line = plotCmd(replot) & equation & " " & extra
  if title != "":
    line.add " title '" & title & "' "
  cmd(line)
  hasPlotted = true

template plotDataImpl(extra: typed) =
  let
    titleLine =
      if title == "": " notitle "
      else: " title '" & title & "' "
    line = plotCmd(replot) & extra & titleLine
  cmd(line)
  hasPlotted = true

proc plot*(equation: string; title, args = ""; replot = true) =
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

proc plot*[T](xs: openarray[T]; title, args = ""; replot = true) =
  ## plot an array or seq of float64 values. e.g.:
  ##
  ## .. code-block:: nim
  ##   import random, sequtils
  ##
  ##   let xs = newSeqWith(20, rand(1.0))
  ##
  ##   plot xs, "random values"
  cmd("$d << EOD")
  for x in xs:
    cmd(fmt(x))
  cmd("EOD")
  plotDataImpl(" $d " & args)

proc plot*[X, Y](xs: openarray[X]; ys: openarray[Y];
    title, args = ""; replot = true) =
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
  cmd("$d << EOD")
  for i in 0 .. high(xs):
    cmd(fmt(xs[i]) & " " & fmt(ys[i]))
  cmd("EOD")
  plotDataImpl(" $d using 1:2 " & args)

proc pdf*(filename = "tmp.pdf"; width = 16.9; height = 12.7) =
  ## script to make gnuplot print into a pdf file
  ## Size is given in cm.
  ## In order to change the font edit gnuplot variable my_font in style_template.
  ##
  ## .. code-block:: nim
  ##   pdf(filename="myProcess.pdf")  # overwrites/creates myProcess.pdf
  cmd("my_export_sz = '" & $width & "," & $height & "'")
  cmd("cmd = exportPdf('" & filename & "')")
  cmd("@cmd")

proc png*(filename = "tmp.png", width = 640, height = 480) =
  ## script to make gnuplot print into a png file
  ## Size is given in pixels.
  ## In order to change the font edit gnuplot variable my_font in style_template.
  ##
  ## .. code-block:: nim
  ##   pdf(filename="myProcess.png")  # overwrites/creates myProcess.png
  cmd("my_export_sz = '" & $width & "," & $height & "'")
  cmd("cmd = exportPdf('" & filename & "')")
  cmd("@cmd")

addExitProc(closeGnuplot)
