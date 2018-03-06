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

proc intersect(ray: Ray, v1: Vec2, v2: Vec2): Option[tuple[point: Vec2, dist: float]] =
  let d = v2 - v1
  let n = d.norm
  let ndir = ray.dir.dot(n)

  if abs(ndir) > 0.00001:
    let t = (ray.orig - v1).dot(n) / -ndir
    let p = ray.orig + ray.dir * t
  
    if abs(d.x) > abs(d.y):
      if p.x.within(v1.x, v2.x):
        result = some((point: p, dist: t))
    else:
      if p.y.within(v1.y, v2.y):
        result = some((point: p, dist: t))

proc intersect(ray: Ray, tile: Tile): Option[tuple[point: Vec2, dist: float]] =
  var tmin = Inf

  for seg in tile.segs:
    let r = ray.intersect(seg.a, seg.b)
    if r.isSome and abs(r.get.dist) < tmin:
      tmin = r.get.dist
      result = some(r.get)

proc intersect(ray: Ray, map: TileMap, layer: TileLayer): Option[tuple[point: Vec2, dist: float]] =
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
      resptr[] = some((r.get.point + offs, r.get.dist))
      result = false
    else:
      result = true
  )

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


if glfw.Init() == 0:
  raise newException(Exception, "Failed to Initialize GLFW")

logging.addHandler(newConsoleLogger())
  
var window = glfw.CreateWindow(1024, 768, "GLFW3 WINDOW", nil, nil)

glfw.MakeContextCurrent(window)
loadExtensions()

proc getStandardLocations(program: GLuint): ProgramLocations =
  return ProgramLocations(
    coords: glGetAttribLocation(program, "a_position"),
    colors: glGetAttribLocation(program, "a_color"),
    texCoords: glGetAttribLocation(program, "a_texcoord"),
    texture: glGetUniformLocation(program, "u_texture")
  )

let handle = initProgram(
  createShader(GL_VERTEX_SHADER, defaultVert),
  createShader(GL_FRAGMENT_SHADER, defaultFrag)
)

let program = Program(
  handle: handle,
  locations: getStandardLocations(handle)
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

let atlas = loadAtlas("../../data/sprites.atlas", textureLoader)
let map = readTilemap("data/level1.json", tileSetLoader)

let tex = textureLoader("logo.png")

#let tex1 = textureLoader("sprites.png")
#let tex2 = textureLoader("sprites2.png")
#let tex3 = textureLoader("sprites3.png")
#let tex4 = textureLoader("sprites4.png")
#let tex5 = textureLoader("sprites5.png")

var batch = newSpriteBatch(program)
var rot = 0.0


var shapes = newShapeBatch()

#echo atlas.dir.cyan.u0 * float atlas.pages[0].width
#echo atlas.dir.cyan.v0 * float atlas.pages[0].height
#echo atlas.dir.cyan.u1 * float atlas.pages[0].width
#echo atlas.dir.cyan.v1 * float atlas.pages[0].height

var frame = 0.0
#echo atlas

var p1 = (x: 32.0*10.0, y: 32.0*9.0)  #vec2(170, 270)
var p2 = (x: 470.0, y: 749.0) #vec2(270, 330)

while glfw.WindowShouldClose(window) == 0:
  glfw.PollEvents()
  glfw.SwapBuffers(window)

  if glfw.GetKey(window,glfw.KEY_ESCAPE) == 1:
      glfw.SetWindowShouldClose(window,1)

  rot += 0.01
  frame += 0.25
  
  #let tmp = vec2(0, 0)
  #tmp.

  var winW, winH: cint
  glfw.GetFramebufferSize(window, addr winW, addr winH)

  glClearColor(0.4, 0.4, 0.4, 1)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glViewport(0, 0, winW, winH)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)



  #batch.draw(tex, -0.5, -0.5, 1, 1)

  #let m = initRot(rot).scl((1 + sin(rot * 4)) / 4 + 0.5, (1 + sin(rot * 4)) / 4 + 0.5).trn(0.2, 0.0)
  
  let proj = map(
    region(0, float winH, float winW, 0),
    region(-1, -1, 1, 1)
  )

  batch.projection = proj
  #let m = proj.trn(winW / 2, winH / 2).rot(rot)
  let m = initRot(rot).trn(-150, -100)

  #batch.draw(initTextureRegion(tex, 10, 10, tex.width-20, tex.height-20),
  #                               -0.5, -0.5, 1, 1, m)

  # batch.draw(initTextureRegion(tex, 0, 0, tex.width, tex.height),
  #                               winW / 2, winH / 2, 300, 200, m)
  

  #batch.draw(atlas.dir.skull, winW / 2, winH / 2, 200, 200, m)

  let anim = atlas.dir.rot
  let fn = int(frame) mod anim.len

  #batch.draw(map.regs[30], 10, 10, 100, 100)
  



  # for layer in map.layers:
  #   for row in 0 ..< layer.height:
  #     for col in 0 ..< layer.width:
  #       let gid = layer[row, col]
  #       if gid != 0:
  #         let tile = map.getTile(gid)
  #         batch.draw(tile.reg, float col * 32, float row * 32, 32, 32)

  
  # batch.drawWithHeight(anim[fn], winW / 2, winH / 2, 200, m)











  #batch.draw(atlas.dir.rot[1], winW / 2, winH / 2, m)



  #batch.draw(atlas.dir.red_bright, -100, -100, 200, 200, m)
  batch.flush()

  shapes.projection = proj
  
  if glfw.GetMouseButton(window, glfw.MOUSE_BUTTON_LEFT) == glfw.PRESS:
    glfw.GetCursorPos(window, addr p2.x, addr p2.y)
  
  if glfw.GetMouseButton(window, glfw.MOUSE_BUTTON_RIGHT) == glfw.PRESS:
    glfw.GetCursorPos(window, addr p1.x, addr p1.y)

  let ray: Ray = (p1, (p2 - p1).unit)
  let res = ray.intersect(map, map.layers[2])

  map.debugDraw(shapes)

  shapes.line(p1, p2, (0.0, 0.0, 0.0, 1.0))
  rayTileMapDebug(shapes, ray, map)

  if res.isSome:
    shapes.circlefill(res.get.point, 3, (1.0, 0.0, 0.0, 1.0))

  shapes.flush()



glfw.DestroyWindow(window)
glfw.Terminate()