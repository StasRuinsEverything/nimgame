import math
import mathutils
import ray

type
  SquareGrid* = object
    bounds*: Rect
    cellSize*: float

proc remf(x: float, dir: float): float =
  if dir < 0: x - floor(x) else: ceil(x) - x

template traverse*(grid: SquareGrid, ray: Ray, maxDist: float, callback: untyped): untyped =
  let md = maxDist / grid.cellSize
  let x0 = ray.orig.x / grid.cellSize
  let y0 = ray.orig.y / grid.cellSize
  var x = int trunc(x0)
  var y = int trunc(y0)
  
  let stepX = if ray.dir.x < 0: -1 else: 1
  let stepY = if ray.dir.y < 0: -1 else: 1
  
  let tPerX = float(stepX) / ray.dir.x
  let tPerY = float(stepY) / ray.dir.y
  
  var tRemX = if ray.dir.x == 0: Inf else: remf(x0, ray.dir.x) * tPerX
  var tRemY = if ray.dir.y == 0: Inf else: remf(y0, ray.dir.y) * tPerY

  var t = 0.0

  while t < md and callback(x, y, t):
    if tRemX < tRemY:
      x += stepX
      t += tRemX
      tRemY -= tRemX
      tRemX = tPerX
    else:
      y += stepY
      t += tRemY
      tRemX -= tRemY
      tRemY = tPerY