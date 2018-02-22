import math
import vec2

type
  Affine2* = object
    data: array[2, array[3, float]]

proc createAffine2*(): Affine2 =
  Affine2(data: [
    [1.0, 0.0, 0.0],
    [0.0, 1.0, 0.0]
  ])

proc createTrn*(tx: float, ty: float): Affine2 =
  Affine2(data: [
    [1.0, 0.0, tx],
    [0.0, 1.0, ty]
  ])

proc createScl*(sx: float, sy: float): Affine2 = 
  Affine2(data: [
    [sx, 0.0, 0.0],
    [0.0, sy, 0.0]
  ])

proc createRot*(rads: float): Affine2 = 
  let c = cos(rads)
  let s = sin(rads)

  Affine2(data: [
    [c, -s, 0.0],
    [s, c, 0.0]
  ])

proc product*(left: Affine2, right: Affine2): Affine2 = 
  template l: untyped = left.data
  template r: untyped = right.data

  Affine2(data: [
    [
      l[0][0] * r[0][0] + l[0][1] * r[1][0],
      l[0][0] * r[0][1] + l[0][1] * r[1][1],
      l[0][0] * r[0][2] + l[0][1] * r[1][2] + l[0][2]
    ],
    [
      l[1][0] * r[0][0] + l[1][1] * r[1][0],
      l[1][0] * r[0][1] + l[1][1] * r[1][1],
      l[1][0] * r[0][2] + l[1][1] * r[1][2] + l[1][2]
    ]
  ])

proc det*(mat: Affine2): float = 
  return mat.data[0][0] * mat.data[1][1] - mat.data[0][1] * mat.data[1][0]

proc inv*(mat: Affine2): Affine2 = 
  let det = mat.det
  let invDet = 1.0 / det
  template m: untyped = mat.data

  Affine2(data: [
    [
      invDet * m[1][1],
      invDet * -m[0][1],
      invDet * (m[0][1] * m[1][2] - m[1][1] * m[0][2])
    ],
    [
      invDet * -m[1][0],
      invDet * m[0][0],
      invDet * (m[1][0] * m[0][2] - m[0][0] * m[1][2])
    ]
  ])

proc mul*(mat: Affine2, other: Affine2): Affine2 = product(mat, other)

proc trn*(mat: Affine2, tx: float, ty: float): Affine2 =
  mat.mul(createTrn(tx, ty))

proc scl*(mat: Affine2, sx: float, sy: float): Affine2 =
  mat.mul(createScl(sx, sy))

proc rot*(mat: Affine2, rads: float): Affine2 =
  mat.mul(createRot(rads))

proc apply*(m: Affine2, v: Vec2): Vec2 =
  Vec2(
    x: m.data[0][0] * v.x + m.data[0][1] * v.y + m.data[0][2],
    y: m.data[1][0] * v.x + m.data[1][1] * v.y + m.data[1][2],
  )