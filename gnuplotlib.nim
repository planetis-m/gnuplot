import osproc, os, streams, strutils

type
   Figure = ref object
      content: string
      idNum: int
      replot: bool

var
   nextIdNum = 0
   currentFigure: Figure

proc newFigure(): Figure =
   ## Initiates a new Figure that communicates with gnuplot
   new(result)
   result.content = newStringOfCap(8_000)
   result.idNum = nextIdNum
   inc(nextIdNum)

proc getCurrentFigure(): Figure =
   currentFigure

proc setCurrentFigure(fig: Figure) =
   currentFigure = fig

template cmd*(cmd: string) =
   ## Send a command to gnuplot
   assert(fig != nil, "Initialize a new Figure with startGnuplot")
   when defined(debugGnuplot): echo cmd
   fig.content.add cmd

proc startGnuplot*() =
   ## Starts gnuplot
   let fig = newFigure()
   setCurrentFigure(fig)
   cmd("load 'setup.gp'")

proc closeGnuplot*() =
   # close figure at the end of the session
   let fig = getCurrentFigure()
   cmd("exit")
   ## Starts gnuplot
   let gnuplotExe = findExe("gnuplot")
   if gnuplotExe == "":
      raise newException(OSError, "Cannot find gnuplot: exe not in PATH")

   let p = startProcess(gnuplotExe, args = ["-persist"])
   let inp = p.inputStream()
   inp.writeLine(fig.content)
   inp.flush()

   discard p.waitForExit()
   if p.hasData():
      let outp = p.outputStream()
      let resp = outp.readAll()
      echo(resp)
   p.close()

template plotCmd(replot: bool): string =
   if replot and fig.replot:
      "replot "
   else:
      "plot "

template plotFunctionImpl(extra: typed) =
   var line = plotCmd(replot) & equation & " " & extra
   if title != "":
      line.add " title '" & title & "' "
   cmd(line)
   fig.replot = true

template plotDataImpl(extra: typed) =
   let
      title_line =
         if title == "": " notitle "
         else: " title '" & title & "' "
      line = plotCmd(replot) & extra & title_line
   cmd(line)
   fig.replot = true

proc plot*(equation: string, title = "", args = "", replot = true) =
   ## Plot an equation as understood by gnuplot. e.g.:
   ##
   ## .. code-block:: nim
   ##   plot "sin(x)/x"
   let fig = getCurrentFigure()
   plotFunctionImpl(args)

template format(x: string): string =
   x

template format(x: float): string =
   formatFloat(x, ffDecimal, 6)

template format(x: untyped): string =
   $x

proc plot*[T](xs: openarray[T], title = "",
              args = "", replot = true) =
   ## plot an array or seq of float64 values. e.g.:
   ##
   ## .. code-block:: nim
   ##   import random, sequtils
   ##
   ##   let xs = newSeqWith(20, random(1.0))
   ##
   ##   plot xs, "random values"
   let fig = getCurrentFigure()
   cmd("$d << EOD")
   for x in xs:
      cmd(format(x))
   cmd("EOD")
   plotDataImpl(" $d " & args)

proc plot*[X, Y](xs: openarray[X], ys: openarray[Y],
                 title = "", args = "", replot = true) =
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
   if xs.len != ys.len:
      raise newException(ValueError, "xs and ys must have same length")
   let fig = getCurrentFigure()
   cmd("$d << EOD")
   for i in low(xs) .. high(xs):
      cmd(format(xs[i]) & " " & format(ys[i]))
   cmd("EOD")
   plotDataImpl(" $d using 1:2 " & args)

proc pdf*(filename = "tmp.pdf", width = 16.9, height = 12.7) =
   ## script to make gnuplot print into a pdf file
   ## Size is given in cm.
   ## In order to change the font edit gnuplot variable my_font in style_template.
   ##
   ## .. code-block:: nim
   ##   pdf(filename="myFigure.pdf")  # overwrites/creates myFigure.pdf
   let fig = getCurrentFigure()
   cmd("my_export_sz = '" & $width & "," & $height & "'")
   cmd("cmd = exportPdf('" & filename & "')")
   cmd("@cmd")

proc png*(filename = "tmp.png", width = 640, height = 480) =
   ## script to make gnuplot print into a png file
   ## Size is given in pixels.
   ## In order to change the font edit gnuplot variable my_font in style_template.
   ##
   ## .. code-block:: nim
   ##   pdf(filename="myFigure.png")  # overwrites/creates myFigure.png
   let fig = getCurrentFigure()
   cmd("my_export_sz = '" & $width & "," & $height & "'")
   cmd("cmd = exportPdf('" & filename & "')")
   cmd("@cmd")

startGnuplot()

addQuitProc(proc() {.noconv.} = closeGnuplot())
