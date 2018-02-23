import vec2
import affine2

type
  Rect* = object
    x*, y*, width*, height*: float
  
  Region* = object
    x0*, y0*, x1*, y1*: float

proc region*(x0, y0, x1, y1: float): Region =
  Region(
    x0: x0,
    y0: y0,
    x1: x1,
    y1: y1
  )

proc rect*(x, y, width, height: float): Rect =
  Rect(
    x: x,
    y: y,
    width: width,
    height: height
  )

proc contains*(r: Rect, x: float, y: float): bool =
  result =
    x >= r.x and
    y >= r.y and
    x < r.x + r.width and
    y < r.y + r.height

proc overlaps*(r1: Rect, r2: Rect): bool =
  not(
    r1.x > r2.x + r2.width or
    r1.y > r2.y + r2.height or
    r2.x > r1.x + r1.width or
    r2.y > r1.x + r1.height
  )

proc map*(src: Region, dest: Region): Affine2 =
  let kx = (dest.x1 - dest.x0) / (src.x1 - src.x0)
  let ky = (dest.y1 - dest.y0) / (src.y1 - src.y0)

  Affine2(data: [
    [kx, 0.0, dest.x0 - src.x0 * kx],
    [0.0, ky, dest.y0 - src.y0 * ky]
  ])

