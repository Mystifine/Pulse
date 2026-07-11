# Computed

A reactive value that automatically updates based on other reactive values.

## Creating a Computed

```lua
local count = Pulse.Value(0)

local doubled = Pulse.Computed(function()
  return count:Get() * 2
end)

print(doubled:Get()) -- 0
count:Set(5)
print(doubled:Get()) -- 10 (automatically updated)
```

## Automatic Dependency Tracking

Computed values automatically track dependencies by monitoring which Values are accessed:

```lua
local x = Pulse.Value(1)
local y = Pulse.Value(2)
local z = Pulse.Value(3)

local computed = Pulse.Computed(function()
  -- This depends on x and y
  return x:Get() + y:Get()
end)

-- Updates trigger when x or y change
x:Set(10) -- computed updates
y:Set(20) -- computed updates
z:Set(30) -- computed does NOT update (not accessed)
```

## Memoization

Computed values are memoized and only recompute when their dependencies change:

```lua
local x = Pulse.Value(1)
local computeCount = 0

local computed = Pulse.Computed(function()
  computeCount = computeCount + 1
  print("Computing... (call #" .. computeCount .. ")")
  return x:Get() * 2
end)

print(computed:Get()) -- Prints: "Computing... (call #1)"
print(computed:Get()) -- Does NOT print (memoized, just returns cached value)
x:Set(2)
print(computed:Get()) -- Prints: "Computing... (call #2)"
```

## Chaining Computations

Computed values can depend on other Computed values:

```lua
local x = Pulse.Value(1)

local doubled = Pulse.Computed(function()
  return x:Get() * 2
end)

local quadrupled = Pulse.Computed(function()
  return doubled:Get() * 2
end)

print(quadrupled:Get()) -- 4
x:Set(5)
print(quadrupled:Get()) -- 20
```

## Changed Signal

Like Values, Computed values emit a `Changed` signal:

```lua
local count = Pulse.Value(0)

local doubled = Pulse.Computed(function()
  return count:Get() * 2
end)

doubled.Changed:Connect(function(newValue)
  print("Doubled changed to:", newValue)
end)

count:Set(5) -- Prints: "Doubled changed to: 10"
```

## Handling Complex Logic

Computed values can contain complex logic and conditionals:

```lua
local score = Pulse.Value(50)

local grade = Pulse.Computed(function()
  local s = score:Get()
  if s >= 90 then return "A"
  elseif s >= 80 then return "B"
  elseif s >= 70 then return "C"
  elseif s >= 60 then return "D"
  else return "F"
  end
end)

print(grade:Get()) -- "F"
score:Set(95)
print(grade:Get()) -- "A"
```

## Side Effects vs Computed

Use Computed for deriving values, use Effects for side effects:

```lua
local x = Pulse.Value(1)

-- Good: Computed for derived values
local doubled = Pulse.Computed(function()
  return x:Get() * 2
end)

-- Good: Effect for logging
Pulse.Effect(function()
  print("Value changed:", x:Get())
end)

-- Bad: Calling print in Computed (it's not really a value derivation)
-- local log = Pulse.Computed(function()
--   print(x:Get())  -- Don't do this!
-- end)
```

## Best Practices

- **Keep computations pure** - Don't modify external state or have side effects
- **Keep computations fast** - Minimize expensive calculations
- **Use for derived state** - Use Computed for values that derive from other values
- **Chain carefully** - Deep chains of computations can impact performance
- **Consider memoization** - Use Computed for expensive calculations that don't change often

## See Also

- [Value](./value.md) - Basic reactive values
- [Effect](./effect.md) - Run side effects
- [Scope](./scope.md) - Lifecycle management
