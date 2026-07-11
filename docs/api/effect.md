# Effect

A side effect that runs whenever its dependencies change.

## Creating an Effect

```lua
local name = Pulse.Value("World")

Pulse.Effect(function()
  print("Hello, " .. name:Get() .. "!")
end)

name:Set("Alice") -- Prints: "Hello, Alice!"
```

## Automatic Dependency Tracking

Like Computed values, Effects automatically track which Values they depend on:

```lua
local x = Pulse.Value(1)
local y = Pulse.Value(2)
local z = Pulse.Value(3)

Pulse.Effect(function()
  print("Sum:", x:Get() + y:Get())
  -- This accesses z, so z is also a dependency
  print("Z:", z:Get())
end)

-- All three updates trigger the effect
x:Set(10)
y:Set(20)
z:Set(30)
```

## Cleanup with Scopes

Effects run immediately when created and whenever their dependencies change. To clean up an effect, destroy its scope:

```lua
local count = Pulse.Value(0)

local _, scope = Pulse.Scope(function()
  Pulse.Effect(function()
    print("Count:", count:Get())
  end)
end)

count:Set(1) -- Prints: "Count: 1"
scope:Destroy()
count:Set(2) -- Does NOT print (effect was destroyed)
```

## Use Cases

### Logging

```lua
local x = Pulse.Value(1)

Pulse.Effect(function()
  print("[DEBUG] x changed to:", x:Get())
end)
```

### Updating UI

```lua
local count = Pulse.Value(0)
local label = Instance.new("TextLabel")

Pulse.Effect(function()
  label.Text = "Count: " .. count:Get()
end)

count:Set(5) -- label.Text updates automatically
```

### Syncing with External Systems

```lua
local position = Pulse.Value(Vector3.new(0, 0, 0))
local humanoidRootPart = workspace:WaitForChild("HumanoidRootPart")

Pulse.Effect(function()
  humanoidRootPart.CFrame = CFrame.new(position:Get())
end)
```

### Playing Animations

```lua
local isAnimating = Pulse.Value(false)

Pulse.Effect(function()
  if isAnimating:Get() then
    game.Debris:AddItem(createAnimationEffect(), 2)
  end
end)
```

## Multiple Dependencies

Effects can depend on multiple Values:

```lua
local firstName = Pulse.Value("John")
local lastName = Pulse.Value("Doe")

Pulse.Effect(function()
  print("Full name:", firstName:Get() .. " " .. lastName:Get())
end)

firstName:Set("Jane") -- Prints: "Full name: Jane Doe"
lastName:Set("Smith") -- Prints: "Full name: Jane Smith"
```

## Conditional Logic

Effects can contain conditionals:

```lua
local count = Pulse.Value(0)

Pulse.Effect(function()
  local value = count:Get()
  if value > 10 then
    print("Count is high!")
  elseif value < 0 then
    print("Count is negative!")
  else
    print("Count is normal")
  end
end)

count:Set(15) -- Prints: "Count is high!"
```

## Error Handling

Errors in effects are wrapped with traceback protection:

```lua
local x = Pulse.Value(1)

Pulse.Effect(function()
  if x:Get() > 5 then
    error("Value too high!")
  end
end)

x:Set(10) -- Will error with traceback
```

## Performance Considerations

- Effects run synchronously when dependencies change
- Keep effects fast to avoid performance issues
- Batch multiple updates before effects run if possible
- Destroy unused effects to prevent memory leaks

## Best Practices

- **Use Effects for side effects** - Don't use Effects to compute and return values
- **Keep effects simple** - Move complex logic into Computed values
- **Clean up properly** - Always destroy scopes to clean up effects
- **Avoid creating effects in loops** - This can cause performance issues
- **Use Effects for UI updates** - Effects are ideal for updating UI when state changes

## See Also

- [Value](./value.md) - Reactive values
- [Computed](./computed.md) - Derived values
- [Scope](./scope.md) - Lifecycle management
