{.experimental.}

import
  engine/application,
  engine/affine2,
  engine/mathutils,
  engine/vec2,
  engine/shapebatch,
  engine/col4,
  util/structural

structural(DynCon, Dyn):
  vel: Vec2
  pos: Vec2

structural(DynCollCon, DynColl):
  vel: Vec2
  pos: Vec2
  bounds: Rect

type
  Box = ref object
    vel: Vec2
    pos: Vec2
    bounds: Rect

  Game = ref object
    dyn: seq[Dyn[RootRef]]


proc addAsDyn(game: Game, obj: Dyn[RootRef]) =
  game.dyn.add(obj)


var app = newApp(width = 800, height = 600, title = "Fugg")
var shapes = newShapeBatch()
var game = Game(
  dyn: @[]
)

game.addAsDyn(Box())

while not app.shouldClose:
  app.frame do (app: var auto, dt: float):
    if app.justPressed(KeySpace) and app.isPressed(KeyLeftControl, KeyLeftShift):
      echo "space pressed!"
    if app.justReleased(KeySpace):
      echo "space released!"

    if app.justPressed(MouseLeft):
      echo "left pressed"
    if app.justReleased(MouseLeft):
      echo "left released"

    app.clearScreen()
    let v = app.mousePos
    let proj = map(
      region(0, app.height, app.width, 0),
      region(-1, -1, 1, 1)
    )
  
    shapes.projection = proj
    shapes.rect(v, 100, 100, col4(1, 1, 1))
    shapes.flush()

app.destroy()