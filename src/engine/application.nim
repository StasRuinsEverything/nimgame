import glfw3 as glfw
import opengl
import logging

type
  MouseButton* = enum
    MouseButton1
    MouseButton2
    MouseButton3
    MouseButton4
    MouseButton5
    MouseButton6
    MouseButton7
    MouseButton8

  Key* = enum
    KeyUnknown = -1

    KeySpace = 32
    KeyApostrophe = 39
    KeyComma = 44
    KeyMinus = 45
    KeyPeriod = 46
    KeySlash = 47

    Key0 = 48
    Key1 = 49
    Key2 = 50
    Key3 = 51
    Key4 = 52
    Key5 = 53
    Key6 = 54
    Key7 = 55
    Key8 = 56
    Key9 = 57

    KeySemicolon = 59
    KeyEqual = 61

    KeyA = 65
    KeyB = 66
    KeyC = 67
    KeyD = 68
    KeyE = 69
    KeyF = 70
    KeyG = 71
    KeyH = 72
    KeyI = 73
    KeyJ = 74
    KeyK = 75
    KeyL = 76
    KeyM = 77
    KeyN = 78
    KeyO = 79
    KeyP = 80
    KeyQ = 81
    KeyR = 82
    KeyS = 83
    KeyT = 84
    KeyU = 85
    KeyV = 86
    KeyW = 87
    KeyX = 88
    KeyY = 89
    KeyZ = 90

    KeyLeftBracket = 91
    KeyBackslash = 92
    KeyRightBracket = 93
    KeyGraveAccent = 96
    KeyWorld1 = 161
    KeyWorld2 = 162
    KeyEscape = 256
    KeyEnter = 257
    KeyTab = 258
    KeyBackspace = 259
    KeyInsert = 260
    KeyDelete = 261
    KeyRight = 262
    KeyLeft = 263
    KeyDown = 264
    KeyUp = 265
    KeyPageUp = 266
    KeyPageDown = 267
    KeyHome = 268
    KeyEnd = 269
    KeyCapsLock = 280
    KeyScrollLock = 281
    KeyNumLock = 282
    KeyPrintScreen = 283
    KeyPause = 284

    KeyF1 = 290
    KeyF2 = 291
    KeyF3 = 292
    KeyF4 = 293
    KeyF5 = 294
    KeyF6 = 295
    KeyF7 = 296
    KeyF8 = 297
    KeyF9 = 298
    KeyF10 = 299
    KeyF11 = 300
    KeyF12 = 301
    KeyF13 = 302
    KeyF14 = 303
    KeyF15 = 304
    KeyF16 = 305
    KeyF17 = 306
    KeyF18 = 307
    KeyF19 = 308
    KeyF20 = 309
    KeyF21 = 310
    KeyF22 = 311
    KeyF23 = 312
    KeyF24 = 313
    KeyF25 = 314

    KeyPad0 = 320
    KeyPad1 = 321
    KeyPad2 = 322
    KeyPad3 = 323
    KeyPad4 = 324
    KeyPad5 = 325
    KeyPad6 = 326
    KeyPad7 = 327
    KeyPad8 = 328
    KeyPad9 = 329
    KeyPadDecimal = 330
    KeyPadDivide = 331
    KeyPadMultiply = 332
    KeyPadSubtract = 333
    KeyPadAdd = 334
    KeyPadEnter = 335
    KeyPadEqual = 336
    
    KeyLeftShift = 340
    KeyLeftControl = 341
    KeyLeftAlt = 342
    KeyLeftSuper = 343
    KeyRightShift = 344
    KeyRightControl = 345
    KeyRightAlt = 346
    KeyRightSuper = 347
    KeyMenu = 348

const MouseLeft* = MouseButton1
const MouseRight* = MouseButton2
const MouseMid* = MouseButton3


const keys* = [
  KeyUnknown,
  KeySpace,
  KeyApostrophe,
  KeyComma,
  KeyMinus,
  KeyPeriod,
  KeySlash,
  Key0,
  Key1,
  Key2,
  Key3,
  Key4,
  Key5,
  Key6,
  Key7,
  Key8,
  Key9,
  KeySemicolon,
  KeyEqual,
  KeyA,
  KeyB,
  KeyC,
  KeyD,
  KeyE,
  KeyF,
  KeyG,
  KeyH,
  KeyI,
  KeyJ,
  KeyK,
  KeyL,
  KeyM,
  KeyN,
  KeyO,
  KeyP,
  KeyQ,
  KeyR,
  KeyS,
  KeyT,
  KeyU,
  KeyV,
  KeyW,
  KeyX,
  KeyY,
  KeyZ,
  KeyLeftBracket,
  KeyBackslash,
  KeyRightBracket,
  KeyGraveAccent,
  KeyWorld1,
  KeyWorld2,
  KeyEscape,
  KeyEnter,
  KeyTab,
  KeyBackspace,
  KeyInsert,
  KeyDelete,
  KeyRight,
  KeyLeft,
  KeyDown,
  KeyUp,
  KeyPageUp,
  KeyPageDown,
  KeyHome,
  KeyEnd,
  KeyCapsLock,
  KeyScrollLock,
  KeyNumLock,
  KeyPrintScreen,
  KeyPause,
  KeyF1,
  KeyF2,
  KeyF3,
  KeyF4,
  KeyF5,
  KeyF6,
  KeyF7,
  KeyF8,
  KeyF9,
  KeyF10,
  KeyF11,
  KeyF12,
  KeyF13,
  KeyF14,
  KeyF15,
  KeyF16,
  KeyF17,
  KeyF18,
  KeyF19,
  KeyF20,
  KeyF21,
  KeyF22,
  KeyF23,
  KeyF24,
  KeyF25,
  KeyPad0,
  KeyPad1,
  KeyPad2,
  KeyPad3,
  KeyPad4,
  KeyPad5,
  KeyPad6,
  KeyPad7,
  KeyPad8,
  KeyPad9,
  KeyPadDecimal,
  KeyPadDivide,
  KeyPadMultiply,
  KeyPadSubtract,
  KeyPadAdd,
  KeyPadEnter,
  KeyPadEqual,
  KeyLeftShift,
  KeyLeftControl,
  KeyLeftAlt,
  KeyLeftSuper,
  KeyRightShift,
  KeyRightControl,
  KeyRightAlt,
  KeyRightSuper,
  KeyMenu,
]

const mouseButtons* = [
  MouseButton1,
  MouseButton2,
  MouseButton3,
  MouseButton4,
  MouseButton5,
  MouseButton6,
  MouseButton7,
  MouseButton8,
]

type
  Application* = ref object
    window: glfw.Window
    lastFrameTime: float
    pressedKeys, lastPressedKeys: set[Key]
    pressedBtns, lastPressedBtns: set[MouseButton]
    clearColor: tuple[r: float, g: float, b: float, a: float]

proc newApp*(width = 800, height = 600, title = "untitled"): Application =
  if glfw.Init() == 0:
    raise newException(Exception, "Failed to Initialize GLFW")
  
  logging.addHandler(newConsoleLogger())
  let window = glfw.CreateWindow(cint width, cint height, title, nil, nil)

  glfw.MakeContextCurrent(window)
  glfw.SwapInterval(0)
  loadExtensions()

  Application(
    window: window,
    clearColor: (0.0, 0.0, 0.0, 1.0)
  )

proc destroy*(app: Application) =
  glfw.DestroyWindow(app.window)
  glfw.Terminate()

proc shouldClose*(app: Application): bool =
  glfw.WindowShouldClose(app.window) == glfw.TRUE

proc clearScreen*(app: Application) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

proc clearColor*(app: Application): tuple[r, g, b, a: float] =
  app.clearColor

proc `clearColor=`*(app: Application, col: tuple[r, g, b, a: float]) =
  app.clearColor = col
  glClearColor(app.clearColor.r, app.clearColor.g, app.clearColor.b, app.clearColor.a)

proc frame*(app: var Application, callback: proc(app: var Application, dt: float)) =
  let time = glfw.GetTime()
  glfw.PollEvents()
  glfw.SwapBuffers(app.window)

  var winW, winH: cint
  glfw.GetFramebufferSize(app.window, addr winW, addr winH)

  for key in keys:
    if glfw.GetKey(app.window, cint key.ord) != glfw.RELEASE:
      app.pressedKeys.incl(key)
    else:
      app.pressedKeys.excl(key)

  for btn in mouseButtons:
    if glfw.GetMouseButton(app.window, cint btn.ord) != glfw.RELEASE:
      app.pressedBtns.incl(btn)
    else:
      app.pressedBtns.excl(btn)

  glViewport(0, 0, winW, winH)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  callback(app, time - app.lastFrameTime)

  app.lastFrameTime = time
  app.lastPressedKeys = app.pressedKeys
  app.lastPressedBtns = app.pressedBtns

proc width*(app: Application): float =
  var winW, winH: cint
  glfw.GetFramebufferSize(app.window, addr winW, addr winH)
  float winW

proc height*(app: Application): float =
  var winW, winH: cint
  glfw.GetFramebufferSize(app.window, addr winW, addr winH)
  float winH

proc mousePos*(app: Application): tuple[x: float, y: float] =
  var x, y: cdouble
  glfw.GetCursorPos(app.window, addr x, addr y)
  (float x, float y)

proc isPressed*(app: Application, keys: varargs[Key]): bool =
  for key in keys:
    if not (key in app.pressedKeys):
      return false
  true

proc justPressed*(app: Application, key: Key): bool =
  key in app.pressedKeys and not (key in app.lastPressedKeys)

proc justReleased*(app: Application, key: Key): bool =
  not (key in app.pressedKeys) and (key in app.lastPressedKeys)

proc isPressed*(app: Application, btns: varargs[MouseButton]): bool =
  for btn in btns:
    if not (btn in app.pressedBtns):
      return false
  true

proc justPressed*(app: Application, btn: MouseButton): bool =
  btn in app.pressedBtns and not (btn in app.lastPressedBtns)

proc justReleased*(app: Application, btn: MouseButton): bool =
  not (btn in app.pressedBtns) and (btn in app.lastPressedBtns)