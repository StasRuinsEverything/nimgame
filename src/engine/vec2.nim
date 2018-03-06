import math

type
  Vec2* = tuple
    x, y: float

proc vec2*(x: float, y: float): Vec2 = (x, y)

proc `+`*(a, b: Vec2): Vec2 = (a.x + b.x, a.y + b.y)
proc `-`*(a, b: Vec2): Vec2 = (a.x - b.x, a.y - b.y)
proc `*`*(v: Vec2, k: float): Vec2 = (v.x * k, v.y * k)

proc `+=`*(a: var Vec2, b: Vec2) =
  a.x += b.x
  a.y += b.y

proc dot*(a, b: Vec2): float = a.x * b.x + a.y * b.y
proc len2*(v: Vec2): float = dot(v, v)
proc len*(v: Vec2): float = sqrt(v.len2)

proc unit*(v: Vec2): Vec2 =
  let len = v.len
  (v.x / len, v.y / len)

proc norm*(v: Vec2): Vec2 = (-v.y, v.x)
proc unitNorm*(v: Vec2): Vec2 = (-v.y, v.y).unit