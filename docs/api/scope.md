# Scope

A container that manages the lifecycle of reactive objects.

## Creating a Scope

```lua
local results, scope = Pulse.Scope(function()
  local value = Pulse.Value(0)
  local doubled = Pulse.Computed(function()
    return value:Get() * 2
  end)
  
  return value, doubled
end)

local value, doubled = results[1], results[2]
```

## Automatic Tracking

When you create reactive objects inside a scope, they're automatically tracked:

```lua
local _, scope = Pulse.Scope(function()
  local value = Pulse.Value(0)
  
  Pulse.Effect(function()
    print(value:Get())
  end)
  
  local computed = Pulse.Computed(function()
    return value:Get() * 2
  end)
end)

-- All three objects are tracked by the scope
```

## Destroying a Scope

When you destroy a scope, all tracked objects are cleaned up:

```lua
local _, scope = Pulse.Scope(function()
  local count = Pulse.Value(0)
  
  Pulse.Effect(function()
    print("Count:", count:Get())
  end)
end)

count:Set(1) -- Prints: "Count: 1"
scope:Destroy()
count:Set(2) -- Does NOT print (effect was destroyed)
```

## Multiple Return Values

Scopes can return multiple values:

```lua
local results, scope = Pulse.Scope(function()
  local x = Pulse.Value(1)
  local y = Pulse.Value(2)
  local sum = Pulse.Computed(function()
    return x:Get() + y:Get()
  end)
  
  return x, y, sum
end)

local x, y, sum = results[1], results[2], results[3]
```

## UI Lifecycle Management

Scopes are perfect for managing UI lifetimes:

```lua
local function createPanel()
  return Pulse.Scope(function()
    local isVisible = Pulse.Value(true)
    
    local screen = Pulse.Create("ScreenGui", {
      Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
    })
    
    Pulse.Effect(function()
      screen.Enabled = isVisible:Get()
    end)
    
    return screen, isVisible
  end)
end

local results, uiScope = createPanel()
local screen, isVisible = results[1], results[2]

-- Later, clean up all effects and computed values
uiScope:Destroy()
```

## Nested Scopes

Scopes can be nested:

```lua
local _, outerScope = Pulse.Scope(function()
  local x = Pulse.Value(1)
  
  local innerResults, innerScope = Pulse.Scope(function()
    local y = Pulse.Value(2)
    return y
  end)
  
  Pulse.Effect(function()
    print(x:Get())
  end)
  
  return innerScope
end)

-- Destroying the outer scope also cleans up nested scopes
outerScope:Destroy()
```

## Error Handling

If an error occurs inside a scope, the scope creation still completes:

```lua
local success = pcall(function()
  local _, scope = Pulse.Scope(function()
    error("Something went wrong!")
  end)
end)

if not success then
  print("Scope creation failed")
end
```

## Use Cases

### Component Lifecycle

```lua
local function createCounter()
  return Pulse.Scope(function()
    local count = Pulse.Value(0)
    
    local container = Pulse.Create("Frame", {})
    
    Pulse.Create("TextButton", {
      Parent = container,
      Text = "Increment",
      Events = {
        Activated = function()
          count:Set(count:Get() + 1)
        end,
      },
    })
    
    local label = Pulse.Create("TextLabel", {
      Parent = container,
      Text = Pulse.Computed(function()
        return "Count: " .. count:Get()
      end),
    })
    
    return container, count
  end)
end

local results, counterScope = createCounter()
local container, count = results[1], results[2]

-- Later, destroy everything
counterScope:Destroy()
```

### Resource Management

```lua
local _, scope = Pulse.Scope(function()
  local position = Pulse.Value(Vector3.new(0, 0, 0))
  local part = Instance.new("Part")
  part.Parent = workspace
  
  Pulse.Effect(function()
    part.Position = position:Get()
  end)
  
  return position, part
end)

-- Later, clean up
scope:Destroy() -- Removes the effect and the part gets destroyed
```

## Best Practices

- **Group related objects** - Use scopes to group logically related reactive objects
- **Clean up when done** - Always destroy scopes when you're finished
- **Use for UI components** - Scopes are ideal for managing UI component lifetimes
- **Nest for structure** - Use nested scopes for hierarchical component structures
- **Handle cleanup** - Remember to destroy scopes when UI is removed

## See Also

- [Value](./value.md) - Reactive values
- [Computed](./computed.md) - Derived values
- [Effect](./effect.md) - Side effects
- [Create](./create.md) - UI creation
