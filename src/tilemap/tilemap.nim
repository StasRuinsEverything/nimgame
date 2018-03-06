import json
import sequtils
import tables
import strutils
import ../engine/textureregion
import ../engine/texture

type
  TileMap* = ref object
    width*: int           # tile columns
    height*: int          # tile rows
    tilesets*: seq[TileSetStub]
    layers*: seq[TileLayer]
    tiles*: seq[Tile]
    tileWidth*: float
    tileHeight*: float

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

  Vec2 = tuple[x: float, y: float]

  Seg = tuple[a: Vec2, b: Vec2]

  Tile* = object
    segs*: seq[Seg]
    reg*: TextureRegion

  TileSet* = ref object
    tex: Texture
    name: string

    columns: int
    tilecount: int
      
    tilewidth: int
    tileheight: int

    spacing: int
    margin: int

    tiles: seq[Tile]

proc cols*(map: TileMap): int = map.width
proc rows*(map: TileMap): int = map.height

proc `[]`*(layer: TileLayer, row: int, col: int): int =
  layer.data[layer.width * row + col]

proc parseVec2(node: JsonNode): Vec2 = (x: node["x"].getFloat, y: node["y"].getFloat)

proc `-`(a: Vec2, b: Vec2): Vec2 = (a.x + b.x, a.y + b.y)

proc parseTileExtras(tile: var Tile, node: JsonNode) =
  if node.hasKey("objectgroup"):
    for objects in node["objectgroup"]["objects"].items:
      let polyline = objects["polyline"]
      let orig = parseVec2(objects)
      var last = parseVec2(polyline[0]) - orig
      
      for i in 1 ..< polyline.len:
        let point = parseVec2(polyline[i]) - orig
        tile.segs.add((last, point))
        last = point

proc readTileSet*(path: string, lookup: proc(path: string): Texture): TileSet =
  var j = json.parseFile(path)
  let tilecount = j["tilecount"].getInt
  
  result = TileSet(
    tex: lookup(j["image"].getStr),
    name: j["name"].getStr,
    columns: j["columns"].getInt,
    tilecount: tilecount,
    tilewidth: j["tilewidth"].getInt,
    tileheight: j["tileheight"].getInt,
    spacing: j["spacing"].getInt,
    margin: j["margin"].getInt,
    tiles: newSeq[Tile](tilecount)
  )

  for i in 0 ..< result.tilecount:
    let row = i div result.columns
    let col = i mod result.columns

    result.tiles[i].reg = initTextureRegion(
      result.tex,
      result.margin + col * (result.tilewidth + result.spacing),
      result.margin + row * (result.tileheight + result.spacing),
      result.tilewidth,
      result.tileheight
    )

    result.tiles[i].segs = @[]

  if j.hasKey("tiles"):
    for field in j["tiles"].pairs:
      parseTileExtras(result.tiles[field.key.parseInt], field.val)

proc getTile*(map: TileMap, gid: int): Tile =
  map.tiles[gid]

proc readTileMap*(path: string, lookup: proc(path: string): TileSet): TileMap =
  var j = json.parseFile(path)
  var map = TileMap(
    width: j["width"].to(int),
    height: j["height"].to(int),
    tileWidth: j["tilewidth"].to(float),
    tileHeight: j["tileheight"].to(float),
    tilesets: j["tilesets"].to(seq[TileSetStub]),
    layers: j["layers"].to(seq[TileLayer]),
    tiles: nil
  )

  var maxGid = 0
  
  for stub in map.tilesets:
    let ts = lookup(stub.source)
    maxGid = max(maxGid, stub.firstgid + ts.tilecount - 1)
  
  map.tiles = newSeq[Tile](maxGid + 1)

  for stub in map.tilesets:
    let ts = lookup(stub.source)
    map.tiles[stub.firstgid ..< stub.firstgid + ts.tilecount] = ts.tiles
  
  result = map