import json
import sequtils
import ../engine/textureregion
import ../engine/texture

type
  TileMap* = object
    width*: int           # tile columns
    height*: int          # tile rows
    tilesets*: seq[TileSetStub]
    layers*: seq[TileLayer]
    regs*: seq[TextureRegion]

  TileLayer* = object
    height*: int          # tile columns
    width*: int           # tile rows
    data*: seq[int]
    opacity*: float
    visible*: bool
    name*: string

  TileSetStub* = object
    source: string
    firstgid: int

  TileSet* = object
    tex: Texture
    name: string

    columns: int
    tilecount: int
      
    tilewidth: int
    tileheight: int

    spacing: int
    margin: int

proc `[]`*(layer: TileLayer, row: int, col: int): int =
  layer.data[layer.width * row + col]

proc readTileSet*(path: string, lookup: proc(path: string): Texture): TileSet =
  var j = json.parseFile(path)
  TileSet(
    tex: lookup(j["image"].getStr),
    name: j["name"].getStr,
    columns: j["columns"].getInt,
    tilecount: j["tilecount"].getInt,
    tilewidth: j["tilewidth"].getInt,
    tileheight: j["tileheight"].getInt,
    spacing: j["spacing"].getInt,
    margin: j["margin"].getInt
  )

proc readTileMap*(path: string, lookup: proc(path: string): TileSet): TileMap =
  var j = json.parseFile(path)
  var map = TileMap(
    width: j["width"].to(int),
    height: j["height"].to(int),
    tilesets: j["tilesets"].to(seq[TileSetStub]),
    layers: j["layers"].to(seq[TileLayer]),
    regs: nil
  )

  var maxGid = 0
  
  for stub in map.tilesets:
    let ts = lookup(stub.source)
    maxGid = max(maxGid, stub.firstgid + ts.tilecount - 1)
  
  map.regs = newSeq[TextureRegion](maxGid + 1)

  for stub in map.tilesets:
    let ts = lookup(stub.source)

    for i in 0 ..< ts.tilecount:
      let row = i div ts.columns
      let col = i mod ts.columns

      map.regs[i + stub.firstgid] = initTextureRegion(
        ts.tex,
        ts.margin + col * (ts.tilewidth + ts.spacing),
        ts.margin + row * (ts.tileheight + ts.spacing),
        ts.tilewidth,
        ts.tileheight
      )
  
  result = map