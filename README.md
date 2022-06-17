# Gnuplot

`gnuplot` interface for Nim. There are 17 predefined styles.

## Examples

```nim
import gnuplot


plot "sin(x)", title = "sin(x)", args = "with lines linestyle 1"
plot "cos(x)", title = "cos(x)", args = "with lines linestyle 2"
```

```nim
import gnuplot, random, sequtils

let xs = newSeqWith(20, rand(1.0))
plot xs, "random values"
```

It has a styling gnuplot macro that is included by default. Functions for printing to
`pdf` and `png` files also exist. `gnuplot/funcs` defines `arange` and `linspace`
iterators and functions.

## Limitations

Does not support multiple concurrent plots. To be done.

## Acknowledgement

- https://github.com/dvolk/gnuplot.nim
