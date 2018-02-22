import texture

type
  TextureRegion* = object
    texture*: Texture
    u0*, v0*, u1*, v1*: float

proc makeTextureRegion*(tex: Texture, x: int, y: int, width: int, height: int): TextureRegion =
  TextureRegion(
    texture: tex,
    u0: x / tex.width,
    v0: y / tex.height,
    u1: (x + width) / tex.width,
    v1: (y + height) / tex.height
  )