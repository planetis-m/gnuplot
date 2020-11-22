
template rangeFloat(incr: untyped): untyped {.dirty.} =
  var res = a
  while res <= b:
    yield res
    incr

iterator `..`[T: SomeFloat](a, b: T): T =
  rangeFloat:
    res += T(1)

iterator arange*[T: SomeFloat](a, b: T, step: T = 1): T =
  rangeFloat:
    res += step

iterator linspace*[T: SomeFloat](a, b: T, num = 50): T =
  let step = (b - a) / T(num - 1) # subtrack 1 to match numpy
  rangeFloat:
    res += step

proc arange*[T: SomeFloat](a, b: T, step: T = 1): seq[T] =
  result = @[]
  for x in arange(a, b, step): add(result, x)

proc linspace*[T: SomeFloat](a, b: T, num = 50): seq[T] =
  result = @[]
  for x in linspace(a, b, num): add(result, x)

when isMainModule:
  import sequtils

  # Tests
  var d: seq[float] = @[]
  for i in 1.0..5.0:
    d.add(i)

  assert d == @[1.0, 2.0, 3.0, 4.0, 5.0]
  assert toSeq(arange(0.0, 20.0, 3.0)) == @[0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0]
  assert toSeq(linspace(0.0, 10.0, 9)) == @[0.0, 1.25, 2.5, 3.75, 5.0, 6.25,
      7.5, 8.75, 10.0]

  assert arange(0.0, 20.0, 3.0) == @[0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0]
  assert linspace(0.0, 10.0, 9) == @[0.0, 1.25, 2.5, 3.75, 5.0, 6.25, 7.5, 8.75, 10.0]
