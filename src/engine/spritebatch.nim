import opengl
import glutils
import texture
import textureregion
import vec2
import affine2
import spriteatlas

type
  ProgramLocations* = object
    coords*: GLint
    colors*: GLint
    tex_coords*: GLint
    texture*: GLint

  Program* = object
    handle*: GLuint
    locations*: ProgramLocations

const cap = 1024 * 3 * 2 # 1024 quads

type
  SpriteBatch* = object
    coordIdx: int
    colorIdx: int
    texCoordIdx: int
    
    coordData: array[cap * 2, float32]
    colorData: array[cap * 4, uint8]
    texCoordData: array[cap * 2, float32]
    
    coordBuff: GLuint
    colorBuff: GLuint
    texCoordBuff: GLuint
    
    program: Program
    lastTexHandle: GLuint
    projection*: Affine2

proc newSpriteBatch*(program: Program): SpriteBatch =
  var batch = SpriteBatch()
  batch.coordBuff = createVbo(batch.coordData, GL_DYNAMIC_DRAW)
  batch.colorBuff = createVbo(batch.colorData, GL_DYNAMIC_DRAW)
  batch.texCoordBuff = createVbo(batch.texCoordData, GL_DYNAMIC_DRAW)
  batch.program = program
  batch.projection = initAffine2()
  return batch
  
proc pushCoord(batch: var SpriteBatch, x: float32, y: float32) =
  batch.coordData[batch.coordIdx + 0] = x
  batch.coordData[batch.coordIdx + 1] = y
  batch.coordIdx += 2

proc pushColor(batch: var SpriteBatch, r: uint8, g: uint8, b: uint8, a: uint8) =
  batch.colorData[batch.colorIdx + 0] = r
  batch.colorData[batch.colorIdx + 1] = g
  batch.colorData[batch.colorIdx + 2] = b
  batch.colorData[batch.colorIdx + 3] = a
  batch.colorIdx += 4

proc pushTexCoord(batch: var SpriteBatch, u: float32, v: float32) =
  batch.texCoordData[batch.texCoordIdx + 0] = u
  batch.texCoordData[batch.texCoordIdx + 1] = v
  batch.texCoordIdx += 2

proc flush*(batch: var SpriteBatch) =
  if batch.coord_idx == 0:
      return

  let locs = batch.program.locations.addr

  glBindBuffer(GL_ARRAY_BUFFER, batch.coordBuff)
  glBufferSubData(GL_ARRAY_BUFFER, 0, batch.coordIdx * sizeof(float32), addr batch.coordData) 
  glEnableVertexAttribArray(GLuint locs.coords)
  glVertexAttribPointer(GLuint locs.coords, 2, cGL_FLOAT, GL_FALSE, 0, nil)
  
  if locs.colors != -1:
    glBindBuffer(GL_ARRAY_BUFFER, batch.colorBuff)
    glBufferSubData(GL_ARRAY_BUFFER, 0, batch.colorIdx, addr batch.colorData) 
    glEnableVertexAttribArray(GLuint locs.colors)
    glVertexAttribPointer(GLuint locs.colors, 4, cGL_UNSIGNED_BYTE, GL_TRUE, 0, nil)

  if locs.tex_coords != -1:
    glBindBuffer(GL_ARRAY_BUFFER, batch.texCoordBuff)
    glBufferSubData(GL_ARRAY_BUFFER, 0, batch.texCoordIdx * sizeof(float32), addr batch.texCoordData) 
    glEnableVertexAttribArray(GLuint locs.texCoords)
    glVertexAttribPointer(GLuint locs.texCoords, 2, cGL_FLOAT, GL_FALSE, 0, nil)

  glUseProgram(batch.program.handle)
  glUniform1i(locs.texture, 0)
  glDrawArrays(GL_TRIANGLES, 0, GLint batch.coordIdx div 2)

  batch.coordIdx = 0
  batch.colorIdx = 0
  batch.texCoordIdx = 0

proc draw*(batch: var SpriteBatch, reg: TextureRegion,
            x: float, y: float, w: float, h: float,
            transf: Affine2 = initAffine2()) =
  let m = batch.projection.trn(x, y).mul(transf)
  let v0 = m.apply((0.0, 0.0))
  let v1 = m.apply((w, 0.0))
  let v2 = m.apply((w, h))
  let v3 = m.apply((0.0, h))

  let (x0, y0) = (float32(v0.x), float32(v0.y))
  let (x1, y1) = (float32(v1.x), float32(v1.y))
  let (x2, y2) = (float32(v2.x), float32(v2.y))
  let (x3, y3) = (float32(v3.x), float32(v3.y))

  if reg.texture.handle != batch.lastTexHandle:
    batch.flush()
    batch.lastTexHandle = reg.texture.handle
    glBindTexture(GL_TEXTURE_2D, reg.texture.handle) 

  batch.pushCoord(x0, y0)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u0, reg.v0)

  batch.pushCoord(x1, y1)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u1, reg.v0)

  batch.pushCoord(x2, y2)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u1, reg.v1)

  batch.pushCoord(x2, y2)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u1, reg.v1)

  batch.pushCoord(x3, y3)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u0, reg.v1)

  batch.pushCoord(x0, y0)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u0, reg.v0)

proc draw*(batch: var SpriteBatch, reg: AtlasRegion,
            x, y, w, h: float, transf: Affine2 = initAffine2()) =
  let m = batch.projection.
    trn(x, y).
    mul(transf).
    scl(w / float reg.logicalWidth, h / float reg.logicalHeight)

  let v0 = m.apply((float reg.xoffs, float reg.yoffs))
  let v1 = m.apply((float reg.xoffs + reg.width, float reg.yoffs))
  let v2 = m.apply((float reg.xoffs + reg.width, float reg.yoffs + reg.height))
  let v3 = m.apply((float reg.xoffs, float reg.yoffs + reg.height))

  let (x0, y0) = (float32(v0.x), float32(v0.y))
  let (x1, y1) = (float32(v1.x), float32(v1.y))
  let (x2, y2) = (float32(v2.x), float32(v2.y))
  let (x3, y3) = (float32(v3.x), float32(v3.y))

  if reg.tex.handle != batch.lastTexHandle:
    batch.flush()
    batch.lastTexHandle = reg.tex.handle
    glBindTexture(GL_TEXTURE_2D, reg.tex.handle) 

  batch.pushCoord(x0, y0)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u0, reg.v0)

  batch.pushCoord(x1, y1)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u1, reg.v0)

  batch.pushCoord(x2, y2)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u1, reg.v1)

  batch.pushCoord(x2, y2)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u1, reg.v1)

  batch.pushCoord(x3, y3)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u0, reg.v1)

  batch.pushCoord(x0, y0)
  batch.pushColor(255, 255, 255, 255)
  batch.pushTexCoord(reg.u0, reg.v0)


# ------------ Simplified overloads ----------------


proc draw*(batch: var SpriteBatch, reg: AtlasRegion,
            x, y: float, transf: Affine2 = initAffine2()) =
  batch.draw(reg, x, y, float reg.logicalWidth, float reg.logicalHeight, transf)

proc drawWithWidth*(batch: var SpriteBatch, reg: AtlasRegion,
                    x, y, width: float, transf: Affine2 = initAffine2()) =
  batch.draw(reg, x, y, width, float(reg.logicalHeight) * width / float(reg.logicalWidth), transf)

proc drawWithHeight*(batch: var SpriteBatch, reg: AtlasRegion,
                      x, y, height: float, transf: Affine2 = initAffine2()) =
  batch.draw(reg, x, y, float(reg.logicalWidth) * height / float(reg.logicalHeight), height, transf)

proc draw*(batch: var SpriteBatch, tex: Texture, x: float, y: float, width: float, height: float) =
  batch.draw(initTextureRegion(tex, 0, 0, tex.width, tex.height), x, y, width, height)


#proc draw*(batch: var SpriteBatch, tex: Texture, x: float, y: float) =
#  batch.draw(tex, x, y, float tex.width, float tex.height)