# Spring

A Spring animation that smoothly animates between values using physics-based spring simulation.

## Creating a Spring

```lua
local target = Pulse.Value(0)
local spring = Pulse.Spring(target)

-- Get the current spring value
print(spring:Get()) -- 0

-- Change the target, the spring animates to it
target:Set(100)
-- spring gradually animates from 0 to 100
```

## Spring Configuration

Customize the spring's behavior with a config object:

```lua
local target = Pulse.Value(0)

local spring = Pulse.Spring(target, {
  frequency = 2,    -- Higher = faster oscillation
  dampingRatio = 0.5, -- Between 0 and 1
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `frequency` | number | 2 | Oscillation frequency |
| `dampingRatio` | number | 0.5 | Damping (0 = no damping, 1 = critical damping) |

## Watching Spring Changes

Springs emit a `Changed` signal as they animate:

```lua
local target = Pulse.Value(0)
local spring = Pulse.Spring(target)

spring.Changed:Connect(function(value)
  print("Spring value:", value)
end)

target:Set(100) -- Prints many times as spring animates
```

## Color Springs

Pulse has built-in support for Color3 springs:

```lua
local targetColor = Pulse.Value(Color3.fromRGB(255, 0, 0))

-- Automatically detects Color3 and creates a color spring
local spring = Pulse.Spring(targetColor)

targetColor:Set(Color3.fromRGB(0, 255, 0)) -- Animates the color smoothly
```

## Using with UI

Springs work great for UI animations:

```lua
local scale = Pulse.Value(1)
local spring = Pulse.Spring(scale)

local part = Pulse.Create("Frame", {
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
  Size = Pulse.Computed(function()
    return UDim2.new(0, 100 * spring:Get(), 0, 100 * spring:Get())
  end),
})

scale:Set(2) -- Frame smoothly scales to 2x
```

## Chaining with Computed

Use springs with computed values:

```lua
local position = Pulse.Value(Vector3.new(0, 0, 0))
local spring = Pulse.Spring(position)

local smoothPosition = Pulse.Computed(function()
  return spring:Get()
end)

Pulse.Effect(function()
  workspace.Part.Position = smoothPosition:Get()
end)

position:Set(Vector3.new(10, 0, 0)) -- Part moves smoothly
```

## Physics Parameters

### Frequency

Higher frequency = faster oscillation:

```lua
-- Slow spring
Pulse.Spring(target, {frequency = 1})

-- Fast spring  
Pulse.Spring(target, {frequency = 5})
```

### Damping Ratio

- `0` = undamped (oscillates forever)
- `0.5` = underdamped (bouncy)
- `1` = critically damped (no overshoot)
- `> 1` = overdamped (slower)

```lua
-- Bouncy
Pulse.Spring(target, {dampingRatio = 0.3})

-- Smooth
Pulse.Spring(target, {dampingRatio = 0.8})
```

## Use Cases

### Smooth Camera Movement

```lua
local targetPos = Pulse.Value(Vector3.new(0, 5, -10))
local springPos = Pulse.Spring(targetPos)

Pulse.Effect(function()
  camera.CFrame = CFrame.new(springPos:Get()) * CFrame.Angles(0, 0, 0)
end)
```

### Button Hover Effects

```lua
local scale = Pulse.Value(1)
local spring = Pulse.Spring(scale)

local button = Pulse.Create("TextButton", {
  Size = Pulse.Computed(function()
    return UDim2.new(0, 100 * spring:Get(), 0, 50 * spring:Get())
  end),
  Events = {
    MouseEnter = function()
      scale:Set(1.1)
    end,
    MouseLeave = function()
      scale:Set(1)
    end,
  },
})
```

### Responsive Values

```lua
local sensitivity = Pulse.Value(0.5)
local springPos = Pulse.Spring(targetPos, {
  frequency = sensitivity:Get() * 10,
})
```

## Best Practices

- **Use for animations** - Springs are perfect for smooth animations
- **Combine with UI** - Use springs to make UI feel responsive
- **Tweak parameters** - Experiment with frequency and damping for the feel you want
- **Clean up springs** - Destroy scopes to clean up springs
- **Avoid over-tuning** - Simple springs with default parameters often work best

## See Also

- [Tween](./tween.md) - Linear animations
- [Value](./value.md) - Reactive values
- [Create](./create.md) - UI creation
