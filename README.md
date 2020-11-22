# Gnuplotlib
gnuplot interface for Nim
### Examples
Plotting is live updating, but only supports a single `gnuplot` process.
Compile with `--threads:on`

```nim
import gnuplotlib

plot "sin(x)", title = "sin(x)", args = "with lines linestyle 1"
plot "cos(x)", title = "cos(x)", args = "with lines linestyle 2"
```

```nim
import gnuplotlib, random, sequtils

let xs = newSeqWith(20, rand(1.0))
plot xs, "random values"
```

Has a styling gnuplot macro that's included by default.
Functions for printing to `pdf` and `png` files also exist.
`gnuplotlib/funcs` defines `arange` and `linspace` iterators and functions.

### Limitations
Does not support multiple concurrent plots. To be done.

### Acknowledgement
- https://github.com/dvolk/gnuplot.nim
