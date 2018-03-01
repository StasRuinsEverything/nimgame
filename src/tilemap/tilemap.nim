import json
import ../engine/textureregion
import ../engine/texture

type
  TileMap* = object
    width*: int           # tile columns
    height*: int          # tile rows
    tilesets*: seq[TileSet]
    layers*: seq[TileLayer]
    regs*: seq[TextureRegion]
  
  TileLayer* = object
    height*: int          # tile columns
    width*: int           # tile rows
    data*: seq[int]
    opacity*: float
    visible*: bool
    name*: string

  TileSet* = object
    image: string
    name: string
    columns: int

    firstgid: int
    tilecount: int
    
    tilewidth: int
    tileheight: int

    spacing: int
    margin: int

proc `[]`*(layer: TileLayer, row: int, col: int): int =
  layer.data[layer.width * row + col]

proc readTileMap*(path: string, lookup: proc(path: string): Texture): TileMap =
  var j = json.parseFile(path)
  var map = TileMap(
    width: j["width"].to(int),
    height: j["height"].to(int),
    tilesets: j["tilesets"].to(seq[TileSet]),
    layers: j["layers"].to(seq[TileLayer]),
    regs: nil
  )

  var maxGid = 0
  
  for ts in map.tilesets:
    maxGid = max(maxGid, ts.firstgid + ts.tilecount - 1)
  map.regs = newSeq[TextureRegion](maxGid + 1)

  for ts in map.tilesets:
    let tex = lookup(ts.image)

    for i in 0 ..< ts.tilecount:
      let row = i div ts.columns
      let col = i mod ts.columns

      map.regs[i + ts.firstgid] = initTextureRegion(
        tex,
        ts.margin + col * (ts.tilewidth + ts.spacing),
        ts.margin + row * (ts.tileheight + ts.spacing),
        ts.tilewidth,
        ts.tileheight
      )
  
  result = map