# Basic Concepts

Pulse is built around a few core concepts that work together to create reactive applications.

## Reactive Values

A **reactive value** is a container that holds data and notifies listeners when that data changes.

```lua
local count = Pulse.Value(0)

-- Get the current value
print(count:Get()) -- 0

-- Set a new value
count:Set(5)
print(count:Get()) -- 5
```

### Changed Signal

Values emit a `Changed` signal when updated:

```lua
local count = Pulse.Value(0)

count.Changed:Connect(function(newValue)
  print("Count changed to:", newValue)
end)

count:Set(5) -- Prints: "Count changed to: 5"
```

## Computed Values

A **computed value** derives its value from other reactive values. It automatically updates when its dependencies change.

```lua
local count = Pulse.Value(0)

local doubled = Pulse.Computed(function()
  return count:Get() * 2
end)

print(doubled:Get()) -- 0
count:Set(5)
print(doubled:Get()) -- 10
```

### Automatic Dependency Tracking

Computed values automatically track their dependencies. Any value accessed within the computation function is considered a dependency:

```lua
local x = Pulse.Value(1)
local y = Pulse.Value(2)

local sum = Pulse.Computed(function()
  return x:Get() + y:Get()
end)

print(sum:Get()) -- 3
x:Set(10)
print(sum:Get()) -- 12
```

## Effects

An **effect** is a side effect that runs whenever its reactive dependencies change.

```lua
local count = Pulse.Value(0)

Pulse.Effect(function()
  print("Count is now:", count:Get())
end)

count:Set(5) -- Prints: "Count is now: 5"
count:Set(10) -- Prints: "Count is now: 10"
```

Effects are useful for:
- Logging and debugging
- Updating UI
- Syncing with external systems
- Running callbacks

## Scopes

A **scope** is a container that manages the lifecycle of reactive objects. When you destroy a scope, all effects and computations within it are cleaned up.

```lua
local results, scope = Pulse.Scope(function()
  local value = Pulse.Value(0)
  local doubled = Pulse.Computed(function()
    return value:Get() * 2
  end)
  
  return value, doubled
end)

local value, doubled = results[1], results[2]

-- Later, clean up everything created in the scope
scope:Destroy()
```

### Scope Tracking

When you create reactive objects inside a scope, they're automatically added to that scope:

```lua
local scope = Pulse.Scope(function()
  -- All of these are automatically tracked by scope
  local value = Pulse.Value(0)
  local doubled = Pulse.Computed(function() return value:Get() * 2 end)
  local effect = Pulse.Effect(function() print(value:Get()) end)
end)

-- Destroying the scope cleans up all tracked objects
scope:Destroy()
```

## Putting It Together

Here's how these concepts work together:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- Create reactive values
local name = Pulse.Value("World")
local greeting = Pulse.Computed(function()
  return "Hello, " .. name:Get() .. "!"
end)

-- Create an effect that runs when greeting changes
Pulse.Effect(function()
  print(greeting:Get())
end)

-- Update the name
name:Set("Alice") -- Prints: "Hello, Alice!"
```

## Next Steps

- Follow the [Quick Start](./quickstart.md) guide to build something practical
- Explore the [API Reference](../api/value.md)
- Check out [Examples](../examples/counter.md)
