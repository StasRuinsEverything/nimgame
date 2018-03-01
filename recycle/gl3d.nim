import glfw3 as glfw
import opengl
import logging
import sequtils
import glutils

type
    ProgramLocations = object
        coords: GLuint
        colors: GLuint
        texCoords: GLuint
        texture: GLuint
        matrix: GLuint

    Program = object
        handle: GLuint
        locations: ProgramLocations

    Mesh = object
        coordBuff: GLuint
        colorBuff: GLuint
        indexBuff: GLuint
        texCoordBuff: GLuint

        vertexNum: GLsizei
        indexNum: GLsizei

proc makeMesh(
        coords: var openArray[float32],
        colors: var openArray[uint8],
        indices: var openArray[uint16],
        texCoords: var openArray[float32]
    ): Mesh =
    var mesh: Mesh

    mesh.coordBuff = glutils.makeVbo(coords, GL_STATIC_DRAW)
    mesh.vertexNum = GLsizei(coords.len div 3)

    if colors.len > 0:
        mesh.colorBuff = makeVbo(colors, GL_STATIC_DRAW)
    if indices.len > 0:
        mesh.indexBuff = makeVbo(indices, GL_STATIC_DRAW)
        mesh.indexNum = GLsizei(indices.len)
    if texCoords.len > 0:
        mesh.texCoordBuff = makeVbo(texCoords, GL_STATIC_DRAW)

    glBindBuffer(GL_ARRAY_BUFFER, 0)

    return mesh


proc draw(mesh: Mesh, locs: ProgramLocations, start: GLsizei, num: GLsizei) =
    glEnableVertexAttribArray(locs.coords)
    glBindBuffer(GL_ARRAY_BUFFER, mesh.coordBuff)
    glVertexAttribPointer(locs.coords, 3, cGL_FLOAT, false, 0, nil)

    if locs.colors != 0:
        glEnableVertexAttribArray(locs.colors)
        glBindBuffer(GL_ARRAY_BUFFER, mesh.colorBuff)
        glVertexAttribPointer(locs.colors, 3, cGL_UNSIGNED_BYTE, true, 0, nil)

#[
    if locs.texCoords != 0:
        glEnableVertexAttribArray(locs.texCoords)
        glBindBuffer(GL_ARRAY_BUFFER, mesh.texCoordBuff)
        glVertexAttribPointer(locs.texCoords, 2, cGL_FLOAT, false, 0, nil)
    
    if mesh.indexBuff != 0:
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.indexBuff)
        glDrawElements(GL_TRIANGLES, mesh.indexNum, cGL_UNSIGNED_SHORT, nil)
    else:
]#
    glDrawArrays(GL_TRIANGLES, start, num)

proc draw(mesh: Mesh, locs: ProgramLocations) =
    draw(mesh, locs, 0, mesh.vertexNum)













const defaultVert = slurp("simple.vert")
const defaultFrag = slurp("simple.frag")

proc getStandardLocations(program: GLuint): ProgramLocations =
    return ProgramLocations(
        coords: GLuint(glGetAttribLocation(program, "a_position")),
        colors: GLuint(glGetAttribLocation(program, "a_color")),
        texCoords: GLuint(glGetAttribLocation(program, "a_texcoord")),
        matrix: GLuint(glGetUniformLocation(program, "u_matrix")),
        texture: GLuint(glGetUniformLocation(program, "u_texture"))
    )






if glfw.Init() == 0:
    raise newException(Exception, "Failed to Initialize GLFW")

logging.addHandler(newConsoleLogger())
    
var window = glfw.CreateWindow(800, 600, "GLFW3 WINDOW", nil, nil)

glfw.MakeContextCurrent(window)
loadExtensions()

let handle = createProgram(
    createShader(GL_VERTEX_SHADER, defaultVert),
    createShader(GL_FRAGMENT_SHADER, defaultFrag)
)

let program = Program(
    handle: handle,
    locations: getStandardLocations(handle)
)

var vertices: array[9, float32] = [
    -0.8'f32, -0.8'f32, 1.0'f32,
    0.0'f32,   0.8'f32, 1.0'f32,
    0.8'f32, -0.8'f32, 1.0'f32
]

var colors: array[9, uint8] = [
    255'u8, 0'u8, 0'u8,
    0'u8, 255'u8, 0'u8,
    0'u8, 0'u8, 255'u8
]
var indices: array[0, uint16] = []
var texCoords: array[0, float32] = []

let mesh = makeMesh(vertices, colors, indices, texCoords)

glutils.logErrors()


while glfw.WindowShouldClose(window) == 0:
    if glfw.GetKey(window,glfw.KEY_ESCAPE) == 1:
        glfw.SetWindowShouldClose(window,1)
    
    glClearColor(1, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT) 

    glUseProgram(program.handle)
    mesh.draw(program.locations)

    glfw.PollEvents()
    glfw.SwapBuffers(window)

glfw.DestroyWindow(window)
glfw.Terminate()