import macros

{.experimental.}
    
proc `-`(a: pointer, b: pointer): int =
  cast[int](a) - cast[int](b)

proc `+`(a: pointer, b: int): pointer =
  cast[pointer](cast[int](a) + cast[int](b))

macro structural*(con, inter, fieldDefs): untyped =
  let dummySym = genSym(nskVar, "dummy")
  let vtableType = newNimNode(nnkTupleTy)
  let vtableValRef = newNimNode(nnkPar)
  let vtableValPtr = newNimNode(nnkPar)
  let conTests = newNimNode(nnkStmtList)
  
  for fieldDef in fieldDefs.children:
    # Build up vtable tuple type and value, as well as concept tests, from the fields:
    let fname = fieldDef[0]
    let ftype = fieldDef[1][0]
  
    var a = newNimNode(nnkIdentDefs)
    a.add(fname)
    a.add(quote do: tuple[offs: int, tmark: `ftype`])
    a.add(newEmptyNode())
    vtableType.add(a)
    
    var b = newNimNode(nnkExprColonExpr)
    b.add(fname)
    b.add(quote do: (addr(`dummySym`.`fname`) - addr(`dummySym`[]), `dummySym`.`fname`))
    vtableValRef.add(b)
    
    var c = newNimNode(nnkExprColonExpr)
    c.add(fname)
    c.add(quote do: (addr(`dummySym`.`fname`) - addr(`dummySym`), `dummySym`.`fname`))
    vtableValPtr.add(c)
    
    conTests.add(quote do: T.`fname` is `ftype`)
  
  
  let node = quote do:
    type
      `con`* = concept g, type T
        `conTests`
  
      `inter`*[T: pointer or RootRef] = object
        base: T
        vtable: ptr[`vtableType`]
    
    # Converter for ref object types:
    # (typedesc is explicitly ruled out to prevent infinite loops in the concept tests)
    converter conToInter*[T: not typedesc and ref object and `con`](x: T): `inter`[RootRef] =
      var vt {.global.} = (proc(): `vtableType` =
        var `dummySym` = T()
        return `vtableValRef`
      )()

      `inter`[RootRef](
        # Questionable cast, but sizeof and repr suggest refs are glorified pointers anyway:
        base: cast[RootRef](x), # Keeps the proxied object alive, provides base address
        vtable: addr vt
      )
    
    # Converter for ptr object types:
    converter conToInter*[T: not typedesc and object and `con`](x: ptr T): `inter`[pointer] =
      var vt {.global.} = (proc(): `vtableType` =
        var `dummySym` = T()
        return `vtableValPtr`
      )()

      `inter`[pointer](
        base: x,
        vtable: addr vt
      )
  
  let node2 = quote("@") do:
    # Syntax sugar for referring to target fields through the proxy
    # This must be separated from the first quote due to issues with the backtick splice
    # Uses the vtable's dummy tmarks to cast to the correct field type
    
    template `.`*[T: pointer or RootRef](x: @inter[T], field: untyped): untyped =
      cast[ptr[(@vtableType).field.tmark]](cast[pointer](x.base) + x.vtable.field.offs)[]
    
    template `.=`*[T: pointer or RootRef](x: @inter[T], field: untyped, value: untyped): untyped =
      cast[ptr[(@vtableType).field.tmark]](cast[pointer](x.base) + x.vtable.field.offs)[] = value
      
  
  
  let node3 = newStmtList()
  
  node3.add(node)
  node3.add(node2)
  #echo node3.repr
  node3