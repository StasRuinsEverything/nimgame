import opengl

type
    PixelFormat* {.pure.} = enum
      RGB,  RGBA
  
    Texture* = object
      width*: int
      height*: int
      handle*: GLuint

proc createTexture*(width: int, height: int, format: PixelFormat, data: var string): Texture =
  let glFormat = case format
    of RGB: GL_RGB
    of RGBA: GL_RGBA
  var handle: GLuint

  glCreateTextures(GL_TEXTURE_2D, 1, addr handle)
  glBindTexture(GL_TEXTURE_2D, handle)
  glTexImage2D(GL_TEXTURE_2D, 0, GLint GL_RGBA, GLsizei width, GLsizei height,
                0, glFormat, GL_UNSIGNED_BYTE, addr data[0])
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

  Texture(
    width: width,
    height: height,
    handle: handle
  )