import strscans
import tables
import macros
import strutils
import sequtils
import algorithm
import texture

#=============== Crappy string stream implementation (Nim's doesn't work at compile time) =======

type
  CtsStream = object
    data: string
    pos: int

proc atEnd(stream: CtsStream): bool =
  stream.pos >= stream.data.len

proc readChar(stream: var CtsStream): char =
  if stream.atEnd:
    result = '\0'
  else:
    result = stream.data[stream.pos]
    inc stream.pos

proc readLine(s: var CtsStream, line: var string): bool =
  line.setLen(0)
  while true:
    var c = readChar(s)
    if c == '\c':
      c = readChar(s)
      break
    elif c == '\L': break
    elif c == '\0':
      if line.len > 0: break
      else: return false
    line.add(c)
  result = true

proc peekLine(s: var CtsStream, line: var string): bool =
  let oldPos = s.pos
  result = s.readLine(line)
  s.pos = oldPos
  
proc initCtsStream(data: string): CtsStream =
  CtsStream(
    pos: 0,
    data: data
  )

template scanl(input: var CtsStream, lineCount: var int, pattern: static[string], results: varargs[untyped]): untyped =
  var line = ""

  if not(stream.readLine(line) and scanf(line, pattern, results)):
    {.line.}:
      raise newException(ValueError, "scanl failed on line #" & $(lineCount + 1) & pattern & line)
  inc lineCount

# ==================== Atlas structures and parser ======================

type
  RegDesc = object
    name: string
    x, y: int
    width, height: int
    logicalWidth, logicalHeight: int
    xoffs, yoffs: int
    index: int
  
  AtlasPage* = object
    width*, height*: int
    path*: string
  
  SpriteAtlas* = object
    pages: seq[AtlasPage]
    dir: Dir
  
  AtlasRegion* = object
    u0*, v0*, u1*, v1*: float
    width*, height*: int
    logicalWidth*, logicalHeight*: int
    xoffs*, yoffs*: int
    tex*: Texture
    page*: int
  
  Dir = Table[string, Entry]
  
  Entry = object
    case leaf: bool
    of true:
      regs: Table[int, AtlasRegion]
    of false:
      dir: Dir

proc insertReg(root: var Dir, reg: AtlasRegion, index: int, path: openArray[string], start: int) =
  if start < path.len - 1:
    insertReg(root.mgetOrPut(
      path[start],
      Entry(leaf: false, dir: initTable[string, Entry]())
    ).dir, reg, index, path, start + 1)
  else:
    root.mgetOrPut(path[start], Entry(
      leaf: true,
      regs: initTable[int, AtlasRegion]()
    )).regs.add(index, reg)

proc parseRegBlock(stream: var CtsStream, lineCount: var int, reg: var RegDesc) =
  var tmp: string
  
  reg.name = ""
  scanl(stream, lineCount, "$*", reg.name)
  scanl(stream, lineCount, "  rotate: $w", tmp)
  scanl(stream, lineCount, "  xy: $i, $i", reg.x, reg.y)
  scanl(stream, lineCount, "  size: $i, $i", reg.width, reg.height)
  scanl(stream, lineCount, "  orig: $i, $i", reg.logicalWidth, reg.logicalHeight)
  scanl(stream, lineCount, "  offset: $i, $i", reg.xoffs, reg.yoffs)
  scanl(stream, lineCount, "  index: $i", reg.index)

proc parseAtlas(stream: var CtsStream, atlas: var SpriteAtlas) =
  var line = ""
  var lineCount = 0
  atlas.pages = @[]
  atlas.dir = initTable[string, Entry]()

  while not stream.atEnd:
    # Read a page:
    var page = AtlasPage()
    page.path = ""

    scanl(stream, lineCount, "")
    scanl(stream, lineCount, "$*", page.path)
    scanl(stream, lineCount, "size: $i,$i", page.width, page.height)
    scanl(stream, lineCount, "")
    scanl(stream, lineCount, "")
    scanl(stream, lineCount, "")
    
    while peekLine(stream, line) and line != "":
      var desc: RegDesc
      
      parseRegBlock(stream, lineCount, desc)

      atlas.dir.insertReg(AtlasRegion(
        u0: desc.x / page.width,
        v0: 1 - desc.y / page.height,
        u1: (desc.x + desc.width) / page.width,
        v1: 1 - (desc.y + desc.height) / page.height,
        logicalWidth: desc.logicalWidth,
        logicalHeight: desc.logicalHeight,
        width: desc.width,
        height: desc.height,
        xoffs: desc.xoffs,
        yoffs: desc.logicalHeight - desc.yoffs - desc.height,
        page: atlas.pages.len
      ), desc.index, desc.name.split("/"), 0)
    
    atlas.pages.add(page)


#proc `$`(reg: RegDesc): string =
#  $reg.x

proc `$`(entry: Entry): string =
  if entry.leaf:
    $entry.regs
  else:
    $entry.dir

proc printEntry(entry: Entry, ind: string)

proc printDir(dir: Dir, ind: string) =
  for key in dir.keys:
    echo ind, key, ":"
    printEntry(dir[key], ind & ind)

proc printEntry(entry: Entry, ind: string) =
  if entry.leaf:
    echo ind, entry.regs
  else:
    printDir(entry.dir, ind)

# ================= Type generators ===============

proc genArrayType(len: int, elemSymNode: NimNode): NimNode {.compileTime.} =
  result = newNimNode(nnkCall).
    add(bindSym("[]", brOpen)).
    add(bindSym("array")).
    add(newIntLitNode(len)).
    add(elemSymNode)

proc genEntryType(entry: Entry): NimNode {.compileTime.} 

proc genDirType(dir: Dir): NimNode {.compileTime.} =
  var t = newNimNode(nnkTupleTy)
  for key in dir.keys:
    t.add(newIdentDefs(ident(key), genEntryType(dir[key])))
  result = t  

proc genEntryType(entry: Entry): NimNode {.compileTime.} =
  if entry.leaf:
    if entry.regs.len > 1:
      result = genArrayType(entry.regs.len, bindSym("AtlasRegion"))
    else:
      result = bindSym("AtlasRegion")
  else:
    result = genDirType(entry.dir)

# ================ Value generators =======================

proc genEntryVal(entry: Entry, pagesSym: NimNode): NimNode {.compileTime.} 

proc genDirVal(dir: Dir, pagesSym: NimNode): NimNode {.compileTime.} =
    var t = newNimNode(nnkPar)
    for key in dir.keys:
      var e = newNimNode(nnkExprColonExpr).
        add(ident(key)).
        add(genEntryVal(dir[key], pagesSym))
      t.add(e)
    result = t  

proc genFieldDef(name: string, val: NimNode): NimNode {.compileTime} =
  newNimNode(nnkExprColonExpr).add(ident(name)).add(val)

proc genRegVal(reg: AtlasRegion, pagesSym: NimNode): NimNode {.compileTime.} =
  result = newNimNode(nnkObjConstr).
    add(bindSym("AtlasRegion")).
    add(genFieldDef("u0", newFloatLitNode(reg.u0))).
    add(genFieldDef("v0", newFloatLitNode(reg.v0))).
    add(genFieldDef("u1", newFloatLitNode(reg.u1))).
    add(genFieldDef("v1", newFloatLitNode(reg.v1))).
    add(genFieldDef("logicalWidth", newIntLitNode(reg.logicalWidth))).
    add(genFieldDef("logicalHeight", newIntLitNode(reg.logicalHeight))).
    add(genFieldDef("width", newIntLitNode(reg.width))).
    add(genFieldDef("height", newIntLitNode(reg.height))).
    add(genFieldDef("xoffs", newIntLitNode(reg.xoffs))).
    add(genFieldDef("yoffs", newIntLitNode(reg.yoffs))).
    add(genFieldDef("page", newIntLitNode(reg.page))).
    add(genFieldDef("tex", newNimNode(nnkCall).
                            add(bindSym("[]", brOpen)).
                            add(pagesSym).
                            add(newIntLitNode(reg.page))))

proc genPagesVal(pages: openArray[AtlasPage], loader: NimNode): NimNode {.compileTime.} =
  result = newNimNode(nnkBracket)
  echo treeRepr loader
  
  for page in pages.items:
    result.add(newNimNode(nnkCall).add(loader).add(newStrLitNode(page.path)))

proc genEntryVal(entry: Entry, pagesSym: NimNode): NimNode {.compileTime.} =
  if entry.leaf:
    if entry.regs.len > 1:
      result = newNimNode(nnkBracket)
      var keys = toSeq(entry.regs.keys)
      keys.sort(system.cmp[int])
      
      for key in keys.items:
        result.add(genRegVal(entry.regs[key], pagesSym))
    else:
      result = genRegVal(entry.regs[-1], pagesSym)
  else:
    result = genDirVal(entry.dir, pagesSym)

#================================================

macro loadAtlas*(file: string, loader: proc(path: string): Texture): untyped =
  var stream = initCtsStream(slurp($file))
  var atlas: SpriteAtlas

  #echo file.symbol.getImpl.strVal

  parseAtlas(stream, atlas)
  
  let pagesSym = genSym(nskLet, "pages")
  let dirType = genDirType(atlas.dir)
  let dirVal = genDirVal(atlas.dir, pagesSym)
  let pagesType = genArrayType(atlas.pages.len, bindSym("Texture"))
  let pagesVal = genPagesVal(atlas.pages, loader)
  
  let x = quote do:
    (proc(): tuple[pages: `pagesType`, dir: `dirType`] = 
      let `pagesSym` = `pagesVal`
      (pages: `pagesSym`, dir: `dirVal`))()
  
  #echo x.repr
  x

#proc crap(path: string): Texture =
#  Texture()

#var x = loadAtlas("data/sprites.atlas", crap)
#echo x

#var stream = initCtsStream(file)
# var atlas: SpriteAtlas
# parseAtlas(stream, atlas)
# echo atlas