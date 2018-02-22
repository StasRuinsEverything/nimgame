import math

type
  Vec2* = object
    x, y: float

proc vec2*(x, y: float): Vec2 = Vec2(x: x, y: y)
proc `+`*(a, b: Vec2): Vec2 = Vec2(x: a.x + b.x, y: a.y + b.y)
proc `-`*(a, b: Vec2): Vec2 = Vec2(x: a.x - b.x, y: a.y - b.y)
proc `*`*(v: Vec2, k: float): Vec2 = Vec2(x: v.x * k, y: v.y * k)

proc dot*(a, b: Vec2): float = a.x * b.x + a.y * b.y
proc len2*(v: Vec2): float = dot(v, v)
proc len*(v: Vec2): float = sqrt(v.len2)

proc unit*(v: Vec2): Vec2 =
  let len = v.len
  vec2(v.x / len, v.y / len)

proc norm*(v: Vec2): Vec2 = vec2(-v.y, v.x)
proc unitNorm*(v: Vec2): Vec2 = vec2(-v.y, v.y).unit