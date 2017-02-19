
template rangeFloat(incr: untyped): untyped {.dirty.} =
  var res = a
  while res <= b:
    yield res
    incr

iterator `..`(a, b: float): float {.inline.} =
  rangeFloat:
    res += 1.0

iterator arange(a, b: float, step = 1.0): float {.inline.} =
  rangeFloat:
    res += step

iterator linspace(a, b: float, num = 50): float {.inline.} =
  let step = (b - a) / float(num - 1) # subtrack 1 to match numpy
  rangeFloat:
    res += step

proc arange(a, b: float, step = 1.0): seq[float] =
  accumulateResult(arange(a, b, step))

proc linspace(a, b: float, num = 50): seq[float] =
  accumulateResult(linspace(a, b, num))


when isMainModule:
  import sequtils

  # Tests
  assert toSeq(1.0..5.0) == @[1.0, 2.0, 3.0, 4.0, 5.0]
  assert toSeq(arange(0.0, 20.0, 3.0)) == @[0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0]
  assert toSeq(linspace(0.0, 10.0, 9)) == @[0.0, 1.25, 2.5, 3.75, 5.0, 6.25, 7.5, 8.75, 10.0]
