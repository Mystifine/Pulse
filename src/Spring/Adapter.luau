local EPSILON = 0.001

local adapter = {}

adapter.number = {
  match = function(value)
    return typeof(value) == "number";
  end,

  zero = 0,
  add = function(a, b) return a + b end,
  sub = function(a, b) return a - b end,
  mul = function(a, b) return a * b end,
  div = function(a, b) return a / b end,

  isClose = function(a, b)
    return math.abs(a - b) < EPSILON;
  end,
}

adapter.Vector2 = {
  match = function(value)
    return typeof(value) == "Vector2";
  end,
  zero = Vector2.new(0, 0),

  add = function(a, b)
    return a + b
  end,

  sub = function(a, b)
    return a - b
  end,

  mul = function(a, b)
    return a * b
  end,

  isClose = function(a, b)
    return (a - b).Magnitude < EPSILON;
  end,
}

adapter.UDim2 = {
  zero = UDim2.new(0, 0, 0, 0),
  match = function(value)
    return typeof(value) == "UDim2";
  end,

  sub = function(a, b)
    return UDim2.new(
      a.X.Scale - b.X.Scale,
      a.X.Offset - b.X.Offset,
      a.Y.Scale - b.Y.Scale,
      a.Y.Offset - b.Y.Offset
    )
  end,

  add = function(a, b)
    return UDim2.new(
      a.X.Scale + b.X.Scale,
      a.X.Offset + b.X.Offset,
      a.Y.Scale + b.Y.Scale,
      a.Y.Offset + b.Y.Offset
    )
  end,

  mul = function(a, t)
    return UDim2.new(
      a.X.Scale * t,
      a.X.Offset * t,
      a.Y.Scale * t,
      a.Y.Offset * t
    )
  end,

  isClose = function(a, b)
    return (a - b).Magnitude < EPSILON;
  end,
}

adapter.Color3 = {
  zero = Color3.new(0, 0, 0),

  sub = function(a, b)
    return Color3.new(
      a.R - b.R,
      a.G - b.G,
      a.B - b.B
    )
  end,

  add = function(a, b)
    return Color3.new(
      a.R + b.R,
      a.G + b.G,
      a.B + b.B
    )
  end,

  mul = function(a, t)
    return Color3.new(
      a.R * t,
      a.G * t,
      a.B * t
    )
  end,

  isClose = function(a, b)
    local dr = a.R - b.R;
    local dg = a.G - b.G;
    local db = a.B - b.B;

    return math.sqrt(dr * dr + dg * dg + db * db) < EPSILON;
  end,

  match = function(value)
    return typeof(value) == "Color3";
  end,
}

local registry = {
  adapter.number,
  adapter.Vector2,
  adapter.UDim2,
  adapter.Color3,
}
function adapter.resolve(value)
  for i = 1, #registry do
    local typeDef = registry[i];
    if typeDef.match(value) then
      return typeDef;
    end
  end

  error("Unsupported spring type: " .. typeof(value))
end

return adapter;