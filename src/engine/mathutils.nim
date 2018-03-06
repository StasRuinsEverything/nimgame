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

proc within*(v: float, a: float, b: float): bool =
  v >= min(a, b) and v <= max(a, b)

proc within*(v: Vec2, p1: Vec2, p2: Vec2): bool =
  result = v.x.within(p1.x, p2.x) and v.y.within(p1.y, p2.y)

proc contains*(r: Region, x: float, y: float): bool =
  result =
    x >= min(r.x0, r.x1) and
    x <= max(r.x0, r.x1) and
    y >= min(r.y0, r.y1) and
    y <= max(r.y0, r.y1)

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

