import glfw3 as glfw
import opengl
import nimPNG
import logging

import glutils
import spritebatch
import texture
import textureregion
import affine2
import math
import mathutils
import vec2
import spriteatlas

const defaultVert = slurp("simple.vert")
const defaultFrag = slurp("simple.frag")












if glfw.Init() == 0:
  raise newException(Exception, "Failed to Initialize GLFW")

logging.addHandler(newConsoleLogger())
  
var window = glfw.CreateWindow(800, 600, "GLFW3 WINDOW", nil, nil)

glfw.MakeContextCurrent(window)
loadExtensions()

proc getStandardLocations(program: GLuint): ProgramLocations =
  return ProgramLocations(
    coords: glGetAttribLocation(program, "a_position"),
    colors: glGetAttribLocation(program, "a_color"),
    texCoords: glGetAttribLocation(program, "a_texcoord"),
    texture: glGetUniformLocation(program, "u_texture")
  )

let handle = createProgram(
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

  createTexture(png.width, png.height, PixelFormat.RGBA, png.data)

let atlas = loadAtlas("data/sprites.atlas", textureLoader)


let tex = textureLoader("logo.png")

#let tex1 = textureLoader("sprites.png")
#let tex2 = textureLoader("sprites2.png")
#let tex3 = textureLoader("sprites3.png")
#let tex4 = textureLoader("sprites4.png")
#let tex5 = textureLoader("sprites5.png")

var batch = newSpriteBatch(program)
var rot = 0.0


#echo atlas.dir.cyan.u0 * float atlas.pages[0].width
#echo atlas.dir.cyan.v0 * float atlas.pages[0].height
#echo atlas.dir.cyan.u1 * float atlas.pages[0].width
#echo atlas.dir.cyan.v1 * float atlas.pages[0].height

var frame = 0.0
echo atlas

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

  glClearColor(0, 0, 0, 1)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glViewport(0, 0, winW, winH)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)



  #batch.draw(tex, -0.5, -0.5, 1, 1)

  #let m = createRot(rot).scl((1 + sin(rot * 4)) / 4 + 0.5, (1 + sin(rot * 4)) / 4 + 0.5).trn(0.2, 0.0)
  
  let proj = map(
    region(0, float winH, float winW, 0),
    region(-1, -1, 1, 1)
  )

  batch.projection = proj
  #let m = proj.trn(winW / 2, winH / 2).rot(rot)
  let m = createRot(rot).trn(-150, -100)

  #batch.draw(makeTextureRegion(tex, 10, 10, tex.width-20, tex.height-20),
  #                               -0.5, -0.5, 1, 1, m)

  batch.draw(makeTextureRegion(tex, 0, 0, tex.width, tex.height),
                                winW / 2, winH / 2, 300, 200, m)
  

  #batch.draw(atlas.dir.skull, winW / 2, winH / 2, 200, 200, m)

  let anim = atlas.dir.rot
  let fn = int(frame) mod anim.len

  batch.drawWithHeight(anim[fn], winW / 2, winH / 2, 200, m)
  #batch.draw(atlas.dir.rot[1], winW / 2, winH / 2, m)



  #batch.draw(atlas.dir.red_bright, -100, -100, 200, 200, m)
  batch.flush()

glfw.DestroyWindow(window)
glfw.Terminate()