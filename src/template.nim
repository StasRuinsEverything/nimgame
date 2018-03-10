import
  engine/application,
  engine/affine2,
  engine/mathutils,
  engine/vec2,
  engine/shapebatch,
  engine/col4

var app = newApp(width = 800, height = 600, title = "Fugg")
var shapes = newShapeBatch()

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