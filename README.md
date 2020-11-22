# Gnuplotlib
gnuplot interface for Nim
### Examples
#### Supports plotting to multiple Figures
```nim
var fig1 = initFigure()
plot "sin(x)", title = "sin(x)", args = "with lines linestyle 1", fig = fig1
plot "cos(x)", title = "cos(x)", args = "with lines linestyle 2", fig = fig1

import random, sequtils

var fig2 = initFigure()
let xs = newSeqWith(20, rand(1.0))
plot xs, "random values", fig = fig2
```

#### Plotting to a global Figure instance
```nim
startGnuplot()

plot "sin(x)", title = "sin(x)", args = "with lines linestyle 1"
plot "cos(x)", title = "cos(x)", args = "with lines linestyle 2"
```

Includes a styling gnuplot macro that's included in every Figure.
Functions for printing to `pdf` and `png` files also included.
`gnuplotlib/funcs` defines `arange` and `linspace` iterators and functions.

Nim destructors close the `Figure` automatically on scope/application exit,
finalizing the plot and sending the data to the gnuplot instance.
This happens sequentially in lifo order.

### Limitations
Does not support live updating plots, a `LiveFigure` might be added in future versions.
