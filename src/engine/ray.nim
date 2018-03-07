import vec2
import options
import mathutils

type
  Ray* = tuple
    orig: Vec2
    dir: Vec2

  RayIntersection* = tuple
    point: Vec2
    norm: Vec2
    dist: float

proc intersect*(ray: Ray, v1: Vec2, v2: Vec2): Option[RayIntersection] =
  let d = v2 - v1
  let n = d.norm
  let ndir = ray.dir.dot(n)

  if abs(ndir) > 0.0001: # Make sure ray is not parallel to the segment
    let t = (ray.orig - v1).dot(n) / -ndir
    let p = ray.orig + ray.dir * t
  
    if abs(d.x) > abs(d.y):
      if p.x.within(v1.x, v2.x):
        result = some((point: p, norm: n, dist: t))
    else:
      if p.y.within(v1.y, v2.y):
        result = some((point: p, norm: n, dist: t))