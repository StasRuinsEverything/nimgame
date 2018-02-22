import glfw3 as glfw
import opengl
import nimPNG
import logging

import glutils
import spritebatch
import texture


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

let png = loadPNG32("logo.png")
let tex = createTexture(png.width, png.height, PixelFormat.RGBA, png.data)
echo png.width, png.height

var batch = newSpriteBatch(program)

while glfw.WindowShouldClose(window) == 0:
    glfw.PollEvents()
    glfw.SwapBuffers(window)

    if glfw.GetKey(window,glfw.KEY_ESCAPE) == 1:
        glfw.SetWindowShouldClose(window,1)
    
    glClearColor(1, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

    batch.draw(tex, -0.5, -0.5, 1, 1)
    batch.flush()

glfw.DestroyWindow(window)
glfw.Terminate()