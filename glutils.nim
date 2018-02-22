import opengl
import logging

proc errorString*(err: GLenum): string =
  case err
  of GL_NO_ERROR: "GL_NO_ERROR"
  of GL_INVALID_ENUM: "GL_INVALID_ENUM"
  of GL_INVALID_VALUE: "GL_INVALID_VALUE"
  of GL_INVALID_OPERATION: "GL_INVALID_OPERATION"
  of GL_INVALID_FRAMEBUFFER_OPERATION: "GL_INVALID_FRAMEBUFFER_OPERATION"
  of GL_OUT_OF_MEMORY: "GL_OUT_OF_MEMORY"
  of GL_STACK_UNDERFLOW: "GL_STACK_UNDERFLOW"
  of GL_STACK_OVERFLOW: "GL_STACK_OVERFLOW"
  else: "<UNKNOWN GL ERROR>"

iterator errors*(): GLenum =
  var err = glGetError()
  while err != GL_NO_ERROR:
    yield err
    err = glGetError()

proc logErrors*() =
  for err in errors():
    logging.warn("OpenGL error: ", errorString(err))

proc makeVbo*[T](data: openarray[T], usage: GLenum): GLuint =
  var buff: GLuint
  glGenBuffers(1, addr(buff))
  glBindBuffer(GL_ARRAY_BUFFER, buff)
  glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(data.len() * sizeof(T)), nil, usage)
  return buff

proc createShader*(shaderType: GLenum, source: string): GLuint =
  let shader = glCreateShader(shaderType)
  let source = allocCStringArray([source])
  var status: GLint

  glShaderSource(shader, GLsizei(1), source, nil)
  glCompileShader(shader)
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr(status))

  deallocCStringArray(source)
  assert(status == GLint(GL_TRUE))
  return shader
  
proc createProgram*(vertexShader: GLuint, fragmentShader: GLuint): GLuint =
  let program = glCreateProgram()
  var status: GLint
  
  glAttachShader(program, vertexShader)
  glAttachShader(program, fragmentShader)
  glLinkProgram(program)

  glGetProgramiv(program, GL_LINK_STATUS, addr(status))
  
  assert(status == GLint(GL_TRUE))
  return program