# Value

A reactive container that holds a value and notifies listeners when it changes.

## Creating a Value

```lua
local count = Pulse.Value(0)
local name = Pulse.Value("Alice")
local position = Pulse.Value(Vector3.new(0, 0, 0))
```

## Getting the Value

Use the `Get()` method to retrieve the current value:

```lua
local count = Pulse.Value(42)
print(count:Get()) -- 42
```

## Setting the Value

Use the `Set()` method to update the value and notify dependents:

```lua
local count = Pulse.Value(0)
count:Set(5)
print(count:Get()) -- 5
```

## Changed Signal

Every Value has a `Changed` signal that fires when the value is updated:

```lua
local count = Pulse.Value(0)

local connection = count.Changed:Connect(function(newValue)
  print("Value changed to:", newValue)
end)

count:Set(5) -- Prints: "Value changed to: 5"
count:Set(10) -- Prints: "Value changed to: 10"

-- Disconnect the listener when you're done
connection:Disconnect()
```

## Reactivity

Values are fully reactive. Any Computed or Effect that accesses a Value will automatically depend on it:

```lua
local x = Pulse.Value(1)
local y = Pulse.Value(2)

local sum = Pulse.Computed(function()
  return x:Get() + y:Get()
end)

print(sum:Get()) -- 3
x:Set(10)
print(sum:Get()) -- 12 (automatically updated)
```

## Type Support

Values can hold any Lua type:

```lua
Pulse.Value(42)                          -- Number
Pulse.Value("hello")                     -- String
Pulse.Value(true)                        -- Boolean
Pulse.Value({a = 1, b = 2})              -- Table
Pulse.Value(Vector3.new(1, 2, 3))        -- Roblox Datatype
Pulse.Value(Instance.new("Part"))        -- Instance
```

## Metadata

Values have a metatable that identifies them as reactive:

```lua
local value = Pulse.Value(42)
print(getmetatable(value)) -- Metatable for Value
```

This is useful for checking if something is a reactive value:

```lua
local function isReactiveValue(obj)
  return typeof(obj) == "table" and getmetatable(obj) == getmetatable(Pulse.Value(0))
end
```

## Best Practices

- **Use Values for mutable state** - Use Values as the source of truth for mutable data
- **Avoid changing Values in loops** - Batch updates when possible
- **Remember to disconnect signals** - Clean up signal connections to prevent memory leaks
- **Combine with Effects** - Use Effects to run side effects when Values change

## See Also

- [Computed](./computed.md) - Derived reactive values
- [Effect](./effect.md) - Side effects
- [Scope](./scope.md) - Lifecycle management
