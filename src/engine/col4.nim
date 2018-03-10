type
  Col4* = tuple[r: float, g: float, b: float, a: float]

proc col4*(r, g, b: float = 0, a: float = 1): Col4 = (r, g, b, a)