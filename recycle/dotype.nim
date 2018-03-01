import macros
import tables
import typetraits
import sequtils
import streams

{. pragma: printMe .}
{. pragma: ignoreMe .}
{. pragma: readbin .}

template transform(p: proc) {.pragma.}

type
    Pragma = object
        name: string
        args: seq[NimNode]
        
    Field = object
        name: string
        typeNode: NimNode
        pragmas: seq[Pragma]

iterator subs[T](indexable: T, a: int, b: int): untyped =
    let a = if a < 0: indexable.len + a else: a
    let b = if b < 0: indexable.len - 1 + b else: b - 1
    for i in a..b:
        yield indexable[i]

proc processPragmaNode(node: NimNode): seq[Pragma] {. compileTime .} =
    node.expectKind(nnkPragma)

    echo node.treeRepr

    toSeq(node.children).map do (x: NimNode) -> Pragma:
        case x.kind:
            of nnkIdent:
                return Pragma(name: $x, args: @[])
            of nnkCall:
                return Pragma(name: $x[0], args: toSeq(x.subs(1, x.len)))
            else:
                error("Unexpected " & $x.kind)
          

proc processIdentDefsNode(node: NimNode): seq[Field] {. compileTime .} =
    node.expectKind(nnkIdentDefs)
    let typeNode = node[^2]
    
    return toSeq(node.subs(0, -2)).map do (x: NimNode) -> Field:
        case x.kind:
            of nnkIdent:
                return Field(
                    name: $x,
                    typeNode: typeNode,
                    pragmas: @[]
                )
            of nnkPragmaExpr:
                return Field(
                    name: $x[0],
                    typeNode: typeNode,
                    pragmas: processPragmaNode(x[1])
                )
            else:
                error("Unexpected " & $x.kind)
            
#IdentDefs = (PragmaExpr | Ident{fieldName})*  Ident{type}
#PragmaExpr = Ident{fieldName} Pragma
#Pragma = (Ident{pragmaName} | Call)*
            
static:
    var procs = initTable[string, proc(name: NimNode, fields: seq[Field]): NimNode]()

macro dotype(stmt: typed): untyped =
    echo stmt.treeRepr

    expectKind(stmt[0], nnkTypeSection)
    for typedef in stmt[0].children:
        let objdef = typedef[2]
        expectKind(objdef, nnkObjectTy)
        
        if objdef[0].kind == nnkPragma:
            for pragma in objdef[0].children:
                if procs.hasKey($pragma):
                    let t: seq[Field] = @[]
                    let fields = toSeq(objdef[2]).foldl(a.concat(processIdentDefsNode(b)), t)
                    stmt.add(procs[$pragma](typedef[0], fields))
    return stmt

proc newsl(nodes: seq[NimNode]): NimNode {. compileTime .} =
    var s = newStmtList()
    for n in nodes.items:
        s.add(n)
    return s

proc hasPragma(field: Field, name: string): bool =
    field.pragmas.any do (p: Pragma) -> bool:
        p.name == name

proc readbin(s: Stream, x: var int8) =
    x = readInt8(s)
    
proc readbin(s: Stream, x: var int16) =
    x = readInt16(s)
    
proc readbin(s: Stream, x: var int32) =
    x = readInt32(s)
    
proc readbin(s: Stream, x: var int64) =
    x = readInt64(s)
    
proc readbin[N, T](s: Stream, x: var array[N, T]) =
    for i in low(x)..high(x):
        readbin(s, x[i])
    
proc printMeGen(name: NimNode, fields: seq[Field]): NimNode {. compileTime .} =
    let sym = genSym(nskParam, "y")
    
    let f = proc(field: Field): bool =
        not hasPragma(field, "ignoreMe")
    
    let pr = fields.filter(f).map do (field: Field) -> NimNode:
        newCall(newIdentNode("echo"), newDotExpr(sym, newIdentNode(field.name)))
    
    let body = newsl(pr)
    
    let x = quote do:
        proc printMe(`sym`: `name`) =
            `body`
    x
    
    
proc readbinGen(name: NimNode, fields: seq[Field]): NimNode {. compileTime .} =
    let syms = genSym(nskParam, "s")
    let symx = genSym(nskParam, "x")

    let pr = fields.map do (field: Field) -> NimNode:
        if field.hasPragma("transform"):
            let tmp = genSym(nskLet, "tmp")
            
            echo "********************"
            echo repr field.pragmas
            #for p in field.pragmas.items:
            #    for a in p.args:
            #        echo a.treeRepr
            echo "********************"
                
            #newVarStmt(tmp, value: NimNode):
            newCall(newIdentNode("echo"), newDotExpr(symx, newIdentNode(field.name)))
        else:
            newCall(newIdentNode("readbin"), syms, newDotExpr(symx, newIdentNode(field.name)))
    
    let body = newsl(pr)
    
    let x = quote do:
        proc readbin(`syms`: Stream, `symx`: var `name`) =
            `body`
            
    echo repr x
    x

proc transf(x: int): string =
    $x

static:
    procs["printMe"] = printMeGen
    procs["readbin"] = readbinGen

dotype:
    type
        Foo = object {. printMe .}
            a: int
            b: float
            c: string
    
        Bar = object {. printMe .}
            a: int
            b: float
            c {. ignoreMe .}: string
                
        Baz = object {. readbin .}
            a: int32
            b {. transform(transf) .}: int64
            c: array[4, int16]
            
        Baz2 = object {. readbin .}
            a: int32
            b: int64
            c: Baz

let bar = Bar(a: 1, b: 2.2, c: "ignored")
echo bar
let foo = Foo(a: 1, b: 6.6, c: "foo")
echo foo



printMe foo
printMe bar


macro my(t: typedesc): untyped =
    echo t.getTypeInst[1].symbol.getImpl.treeRepr
    #let pragmaNode = t.getTypeInst[1].symbol.getImpl[2][2][0][0][1]
    #echo pragmaNode.treeRepr
    #echo processPragmaNode(pragmaNode).repr # [1].symbol.getImpl.treeRepr
  
my(Baz)