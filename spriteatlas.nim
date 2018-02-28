import texture

type
  AtlasPage* = object
    width*, height*: int
    path*: string

  AtlasRegion* = object
    u0*, v0*, u1*, v1*: float
    width*, height*: int
    logicalWidth*, logicalHeight*: int
    xoffs*, yoffs*: int
    tex*: Texture
    page*: int