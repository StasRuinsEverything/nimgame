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



proc textureLoader(path: string): Texture =
  let png = loadPNG32("data/" & path)
  createTexture(png.width, png.height, PixelFormat.RGBA, png.data)

let atlas = loadAtlas("data/sprites.atlas", textureLoader)


let tex = textureLoader("logo.png")

var batch = newSpriteBatch(program)
var rot = 0.0


echo atlas.dir.cyan.u0 * float atlas.pages[0].width
echo atlas.dir.cyan.v0 * float atlas.pages[0].height
echo atlas.dir.cyan.u1 * float atlas.pages[0].width
echo atlas.dir.cyan.v1 * float atlas.pages[0].height

while glfw.WindowShouldClose(window) == 0:
  glfw.PollEvents()
  glfw.SwapBuffers(window)

  if glfw.GetKey(window,glfw.KEY_ESCAPE) == 1:
      glfw.SetWindowShouldClose(window,1)

  rot += 0.01
  
  #let tmp = vec2(0, 0)
  #tmp.

  var winW, winH: cint
  glfw.GetFramebufferSize(window, addr winW, addr winH)

  glClearColor(1, 0, 0, 1)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glViewport(0, 0, winW, winH)



  #batch.draw(tex, -0.5, -0.5, 1, 1)

  #let m = createRot(rot).scl((1 + sin(rot * 4)) / 4 + 0.5, (1 + sin(rot * 4)) / 4 + 0.5).trn(0.2, 0.0)
  
  let proj = map(
    region(0, float winH, float winW, 0),
    region(-1, -1, 1, 1)
  )


  let m = proj.trn(winW / 2, winH / 2).rot(rot)


  # batch.draw(makeTextureRegion(tex, 10, 10, tex.width-20, tex.height-20),
  #                               -0.5, -0.5, 1, 1, m)

  #batch.draw(makeTextureRegion(atlas.dir.cyan.tex, 0, 0, atlas.pages[0].width, atlas.pages[0].height),
  #                              -100, -100, 200, 200, m)
  
  batch.draw(atlas.dir.red_bright, -100, -100, 200, 200, m)
  batch.flush()

glfw.DestroyWindow(window)
glfw.Terminate()