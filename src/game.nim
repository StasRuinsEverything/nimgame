import glfw3 as glfw
import opengl
import nimPNG
import logging
import math
import options

import
  engine/glutils,
  engine/spritebatch,
  engine/texture,
  engine/textureregion,
  engine/affine2,
  engine/mathutils,
  engine/vec2,
  engine/spriteatlasloader,
  engine/shapebatch,
  engine/mathutils,
  engine/squaregrid,
  engine/ray,
  tilemap/tilemap

const defaultVert = slurp("simple.vert")
const defaultFrag = slurp("simple.frag")

type
  Player = object
    pos: Vec2
    vel: Vec2
    width: float
    height: float

const grav = 800.0

proc move(p: var Player, dt: float) =
  p.vel.y += grav * dt
  p.pos += p.vel * dt

proc bounce(vel: Vec2, norm: Vec2, elast: float, frict: float): Vec2 =
  let t = norm.norm
  let vn = vel.dot(norm) * -elast
  let vt = vel.dot(t) * frict
  norm * vn + t * vt


proc intersect(ray: Ray, tile: Tile): Option[RayIntersection] =
  var tmin = Inf

  for seg in tile.segs:
    let r = ray.intersect(seg.a, seg.b)
    if r.isSome and abs(r.get.dist) < tmin:
      tmin = r.get.dist
      result = some(r.get)

proc intersect(ray: Ray, map: TileMap, layer: TileLayer): Option[RayIntersection] =
  let grid = SquareGrid(
    bounds: rect(0, 0, float(map.cols) * map.tileWidth, float(map.rows) * map.tileHeight),
    cellSize: map.tileWidth
  )
  var resptr = addr result

  grid.traverse(ray, 2000, proc(col: int, row: int, t: float): bool =
    if not map.validLoc(col, row):
      return false
    
    let offs = vec2(float(col) * 32, float(row) * 32)
    let ray2 = (
      orig: ray.orig - offs,
      dir: ray.dir
    )
    var r = ray2.intersect(map.getTile(layer[row, col]))

    if r.isSome:
      let r = r.get
      resptr[] = some((r.point + offs, r.norm, r.dist))
      result = false
    else:
      result = true
  )


proc castVert(map: TileMap, layer: TileLayer, srcX, srcY, destY: float): Option[RayIntersection] =
  let grid = SquareGrid(
    bounds: rect(0, 0, float(map.cols) * map.tileWidth, float(map.rows) * map.tileHeight),
    cellSize: map.tileWidth
  )
  
  let col = grid.toCol(srcX)
  var row = clamp(grid.toRow(srcY), 0, map.rows - 1)
  var destRow = clamp(grid.toRow(destY), 0, map.rows - 1)
  var step = if srcY < destY: 1 else: -1

  while true:
    let offs = vec2(float(col) * map.tileWidth, float(row) * map.tileHeight)
    let ray = (
      (srcX - offs.x, srcY - offs.y),
      (0.0, float(step))
    )
    var r = ray.intersect(map.getTile(layer[row, col]))

    if r.isSome:
      let r = r.get
      result = some((r.point + offs, r.norm, r.dist))
      break
    
    if row == destRow:
      break
    
    row += step
    




proc rayTileMapDebug(shapes: var ShapeBatch, ray: Ray, map: TileMap) =
  let grid = SquareGrid(
    bounds: rect(0, 0, float(map.cols) * map.tileWidth, float(map.rows) * map.tileHeight),
    cellSize: map.tileWidth
  )

  let shapesPtr = addr shapes
  proc dummy(x: int, y: int, t: float): bool =
    shapesPtr[].circlefill((
      float(x) * grid.cellSize + grid.cellSize / 2,
      float(y) * grid.cellSize + grid.cellSize / 2), 
    3, (0.0, 0.0, 0.0, 1.0))
    result = true

  for i in 0 .. int(grid.bounds.height / grid.cellSize):
    for j in 0 .. int(grid.bounds.width / grid.cellSize):
      var col = if (i + j) mod 2 == 0: (0.0, 0.0, 0.0, 0.2) else: (0.0, 0.0, 0.0, 0.25)
      shapes.rectfill(
        (float(j) * grid.cellSize, float(i) * grid.cellSize),
        grid.cellSize, grid.cellSize, col
      )
  
  grid.traverse(ray, 2000, dummy)

proc debugDraw(map: TileMap, shapes: var ShapeBatch) =
  for layer in map.layers:
    for row in 0 ..< layer.height:
      for col in 0 ..< layer.width:
        let gid = layer[row, col]
        if gid != 0:
          let tile = map.getTile(gid)
          for seg in tile.segs:
            let x = float(col) * 32.0
            let y = float(row) * 32.0
            shapes.line(seg.a + (x, y), seg.b + (x, y), (1.0, 0.0, 0.0, 1.0))

proc draw(batch: var SpriteBatch, map: TileMap) =
  for layer in map.layers:
    for row in 0 ..< layer.height:
      for col in 0 ..< layer.width:
        let gid = layer[row, col]
        if gid != 0:
          let tile = map.getTile(gid)
          batch.draw(tile.reg, float col * 32, float row * 32, 32, 32)




proc getStandardLocations(program: GLuint): ProgramLocations =
  return ProgramLocations(
    coords: glGetAttribLocation(program, "a_position"),
    colors: glGetAttribLocation(program, "a_color"),
    texCoords: glGetAttribLocation(program, "a_texcoord"),
    texture: glGetUniformLocation(program, "u_texture")
  )

proc `[]`(png: PNGResult, x, y: int): tuple[r: char, g: char, b: char, a: char] =
 let i = (y * png.width + x) * 4
 (png.data[i + 0], png.data[i + 1], png.data[i + 2], png.data[i + 3])

proc `[]=`(png: PNGResult, x, y: int, color: tuple[r: char, g: char, b: char, a: char]) =
  let i = (y * png.width + x) * 4
  png.data[i + 0] = color.r
  png.data[i + 1] = color.g
  png.data[i + 2] = color.b
  png.data[i + 3] = color.a

proc textureLoader(path: string): Texture =
  let png = loadPNG32("data/" & path)

  for y in 0 ..< png.height div 2:
    for x in 0 ..< png.width:
      let tmp = png[x, png.height - 1 - y]
      png[x, png.height - 1 - y] = png[x, y]
      png[x, y] = tmp

  initTexture(png.width, png.height, PixelFormat.RGBA, png.data)

proc tileSetLoader(path: string): TileSet =
  readTileSet("data/" & path, textureLoader)


























if glfw.Init() == 0:
  raise newException(Exception, "Failed to Initialize GLFW")

logging.addHandler(newConsoleLogger())
  
var window = glfw.CreateWindow(1024, 768, "GLFW3 WINDOW", nil, nil)

glfw.MakeContextCurrent(window)
loadExtensions()


let handle = initProgram(
  createShader(GL_VERTEX_SHADER, defaultVert),
  createShader(GL_FRAGMENT_SHADER, defaultFrag)
)

let program = Program(
  handle: handle,
  locations: getStandardLocations(handle)
)

let atlas = loadAtlas("../../data/sprites.atlas", textureLoader)
let map = readTilemap("data/level1.json", tileSetLoader)

var batch = newSpriteBatch(program)
var rot = 0.0


var shapes = newShapeBatch()

var frame = 0.0

var p1 = (x: 32.0*10.0, y: 32.0*9.0)  #vec2(170, 270)
var p2 = (x: 470.0, y: 749.0) #vec2(270, 330)

var player = Player(
  pos: vec2(100, 100),
  width: 30,
  height: 50
)

var lastTime = glfw.GetTime()

while glfw.WindowShouldClose(window) == 0:
  let time = glfw.GetTime()

  glfw.PollEvents()
  glfw.SwapBuffers(window)

  if glfw.GetKey(window,glfw.KEY_ESCAPE) == 1:
      glfw.SetWindowShouldClose(window,1)

  if glfw.GetMouseButton(window, glfw.MOUSE_BUTTON_LEFT) == glfw.PRESS:
    player.vel.y = 0
    player.vel.x = 0
    glfw.GetCursorPos(window, addr player.pos.x, addr player.pos.y)



  #player.vel.x += 1500 * (time - lastTime)
  player.move(time - lastTime)

  let srcY = player.pos.y + player.height / 2

  let res1 = map.castVert(
    map.layers[2],
    player.pos.x - player.width / 2,
    srcY - 10,
    srcY + 100
  )

  let res2 = map.castVert(
    map.layers[2],
    player.pos.x + player.width / 2,
    srcY - 10,
    srcY + 100
  )

  let flag1 = res1.isSome and res1.get.dist < 10
  let flag2 = res2.isSome and res2.get.dist < 10

  if flag1 or flag2:
    let y1 = if res1.isSome: res1.get.point.y else: srcY
    let y2 = if res2.isSome: res2.get.point.y else: srcY

    if y1 < y2:
      player.pos.y = min(y1, y2) - player.height / 2
      player.vel = player.vel.bounce(res1.get.norm.unit, 0, 0.9)
      echo res1.get.norm.unit
    else:
      player.pos.y = min(y1, y2) - player.height / 2
      player.vel = player.vel.bounce(res2.get.norm.unit, 0, 0.9)
      echo res2.get.norm.unit








  rot += 0.01
  frame += 0.25
  
  var winW, winH: cint
  glfw.GetFramebufferSize(window, addr winW, addr winH)

  glClearColor(0.4, 0.4, 0.4, 1)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glViewport(0, 0, winW, winH)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

  let proj = map(
    region(0, float winH, float winW, 0),
    region(-1, -1, 1, 1)
  )

  batch.projection = proj
  batch.draw(map)
  batch.flush()

  shapes.projection = proj

  map.debugDraw(shapes)

  shapes.rectfill(
    player.pos.x - player.width / 2,
    player.pos.y - player.height / 2,
    player.width,
    player.height,
    (0.0, 0.0, 1.0, 0.3)
  )

  shapes.rect(
    player.pos.x - player.width / 2,
    player.pos.y - player.height / 2,
    player.width,
    player.height,
    (0.0, 0.0, 1.0, 1.0)
  )

  # if glfw.GetMouseButton(window, glfw.MOUSE_BUTTON_LEFT) == glfw.PRESS:
  #   glfw.GetCursorPos(window, addr p2.x, addr p2.y)
  
  # if glfw.GetMouseButton(window, glfw.MOUSE_BUTTON_RIGHT) == glfw.PRESS:
  #   glfw.GetCursorPos(window, addr p1.x, addr p1.y)

  # let ray: Ray = (p1, (p2 - p1).unit)
  # let res = ray.intersect(map, map.layers[2])

  # shapes.line(p1, p2, (0.0, 0.0, 0.0, 1.0))
  # rayTileMapDebug(shapes, ray, map)

  # if res.isSome:
  #   shapes.circlefill(res.get.point, 3, (1.0, 0.0, 0.0, 1.0))

  shapes.flush()
  lastTime = time



glfw.DestroyWindow(window)
glfw.Terminate()