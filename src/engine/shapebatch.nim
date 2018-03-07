import opengl
import glutils
import vec2
import affine2
import math

const vertShader = """
attribute vec4 a_position;
attribute vec4 a_color;

varying vec4 v_color;
varying vec2 v_texcoord;

void main() {
    gl_Position = a_position;
    v_color = a_color;
}
"""

const fragShader = """
precision mediump float;
varying vec4 v_color;

void main() {
    gl_FragColor = v_color;
}
"""

type
  ShapeMode* = enum
    smLine, smFill

  ProgramLocations = object
    coords*: GLint
    colors*: GLint

  Program = object
    handle*: GLuint
    locations*: ProgramLocations

  Color = tuple
    r: float
    g: float
    b: float
    a: float

const cap = 1024 * 3 * 2 # 1024 quads

type
  ShapeBatch* = object
    coordIdx: int
    colorIdx: int
    
    coordData: array[cap * 2, float32]
    colorData: array[cap * 4, uint8]
    
    coordBuff: GLuint
    colorBuff: GLuint
    
    program: Program
    projection*: Affine2
    mode: ShapeMode

proc newShapeBatch*(): ShapeBatch =
  let handle = initProgram(
    createShader(GL_VERTEX_SHADER, vertShader),
    createShader(GL_FRAGMENT_SHADER, fragShader)
  )

  let locs = ProgramLocations(
    coords: glGetAttribLocation(handle, "a_position"),
    colors: glGetAttribLocation(handle, "a_color"),
  )

  
  let program = Program(
    handle: handle,
    locations: locs
  )

  var batch = ShapeBatch()

  batch.coordBuff = createVbo(batch.coordData, GL_DYNAMIC_DRAW)
  batch.colorBuff = createVbo(batch.colorData, GL_DYNAMIC_DRAW)
  batch.program = program
  batch.projection = initAffine2()
  batch.mode = smLine

  result = batch

proc pushCoord(batch: var ShapeBatch, x: float32, y: float32) =
  batch.coordData[batch.coordIdx + 0] = x
  batch.coordData[batch.coordIdx + 1] = y
  batch.coordIdx += 2

proc pushColor(batch: var ShapeBatch, r: uint8, g: uint8, b: uint8, a: uint8) =
  batch.colorData[batch.colorIdx + 0] = r
  batch.colorData[batch.colorIdx + 1] = g
  batch.colorData[batch.colorIdx + 2] = b
  batch.colorData[batch.colorIdx + 3] = a
  batch.colorIdx += 4

proc pushColor(batch: var ShapeBatch, col: Color) =
  batch.pushColor(
    uint8(min(max(col.r, 0), 1) * 255),
    uint8(min(max(col.g, 0), 1) * 255),
    uint8(min(max(col.b, 0), 1) * 255),
    uint8(min(max(col.a, 0), 1) * 255)
  )

proc flush*(batch: var ShapeBatch) =
  if batch.coord_idx == 0:
      return

  let locs = batch.program.locations.addr

  glBindBuffer(GL_ARRAY_BUFFER, batch.coordBuff)
  glBufferSubData(GL_ARRAY_BUFFER, 0, batch.coordIdx * sizeof(float32), addr batch.coordData) 
  glEnableVertexAttribArray(GLuint locs.coords)
  glVertexAttribPointer(GLuint locs.coords, 2, cGL_FLOAT, GL_FALSE, 0, nil)
  
  glBindBuffer(GL_ARRAY_BUFFER, batch.colorBuff)
  glBufferSubData(GL_ARRAY_BUFFER, 0, batch.colorIdx, addr batch.colorData) 
  glEnableVertexAttribArray(GLuint locs.colors)
  glVertexAttribPointer(GLuint locs.colors, 4, cGL_UNSIGNED_BYTE, GL_TRUE, 0, nil)

  glUseProgram(batch.program.handle)
  glDrawArrays(if batch.mode == smFill: GL_TRIANGLES else: GL_LINES, 0, GLint batch.coordIdx div 2)

  batch.coordIdx = 0
  batch.colorIdx = 0

proc line*(batch: var ShapeBatch, x0: float, y0: float, x1: float, y1: float, col: Color) =
  let v0 = batch.projection.apply((x0, y0))
  let v1 = batch.projection.apply((x1, y1))
  let (x0, y0) = (float32(v0.x), float32(v0.y))
  let (x1, y1) = (float32(v1.x), float32(v1.y))

  if batch.mode != smLine or batch.coordIdx == cap:
    batch.flush()
    batch.mode = smLine
  
  batch.pushCoord(x0, y0)
  batch.pushColor(col)
  
  batch.pushCoord(x1, y1)
  batch.pushColor(col)

proc line*(batch: var ShapeBatch, a: Vec2, b: Vec2, col: Color) =
  batch.line(a.x, a.y, b.x, b.y, col)

proc trifill*(batch: var ShapeBatch, a: Vec2, b: Vec2, c: Vec2, col: Color) =
  let v0 = batch.projection.apply(a)
  let v1 = batch.projection.apply(b)
  let v2 = batch.projection.apply(c)
  let (x0, y0) = (float32(v0.x), float32(v0.y))
  let (x1, y1) = (float32(v1.x), float32(v1.y))
  let (x2, y2) = (float32(v2.x), float32(v2.y))

  if batch.mode != smFill or batch.coordIdx == cap:
    batch.flush()
    batch.mode = smFill
  
  batch.pushCoord(x0, y0)
  batch.pushColor(col)
  
  batch.pushCoord(x1, y1)
  batch.pushColor(col)

  batch.pushCoord(x2, y2)
  batch.pushColor(col)

proc rect*(batch: var ShapeBatch, x, y, width, height: float, col: Color) =
  batch.line(x, y, x + width, y, col)
  batch.line(x + width, y, x + width, y + height, col)
  batch.line(x + width, y + height, x, y + height, col)
  batch.line(x, y + height, x, y, col)

proc rect*(batch: var ShapeBatch, pos: Vec2, width: float, height: float, col: Color) =
  batch.line(pos.x, pos.y, pos.x + width, pos.y, col)
  batch.line(pos.x + width, pos.y, pos.x + width, pos.y + height, col)
  batch.line(pos.x + width, pos.y + height, pos.x, pos.y + height, col)
  batch.line(pos.x, pos.y + height, pos.x, pos.y, col)

proc rectfill*(batch: var ShapeBatch, x, y, width, height: float, col: Color) =
  batch.trifill(
    (x, y),
    (x + width, y),
    (x + width, y + height),
    col
  )

  batch.trifill(
    (x + width, y + height),
    (x, y + height),
    (x, y),
    col
  )

proc rectfill*(batch: var ShapeBatch, pos: Vec2, width: float, height: float, col: Color) =
  batch.rectfill(pos.x, pos.y, width, height, col)

proc circle*(batch: var ShapeBatch, pos: Vec2, rad: float, col: Color) =
  var lastX = pos.x + rad
  var lastY = pos.y
  let pi2 = 2 * math.PI
  let n = 35

  for i in 0 ..< n:
    let x = pos.x + rad * cos(float(i) * pi2 / float(n - 1))
    let y = pos.y + rad * sin(float(i) * pi2 / float(n - 1))
    batch.line(lastX, lastY, x, y, col)
    lastX = x
    lastY = y

proc circlefill*(batch: var ShapeBatch, pos: Vec2, rad: float, col: Color) =
  var lastX = pos.x + rad
  var lastY = pos.y
  let pi2 = 2 * math.PI
  let n = 35

  for i in 0 ..< n:
    let x = pos.x + rad * cos(float(i) * pi2 / float(n - 1))
    let y = pos.y + rad * sin(float(i) * pi2 / float(n - 1))
    batch.trifill((lastX, lastY), (x, y), (pos.x, pos.y), col)
    lastX = x
    lastY = y