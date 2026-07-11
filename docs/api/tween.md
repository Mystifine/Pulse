# Tween

A linear animation that smoothly transitions between values over a specified duration.

## Creating a Tween

```lua
local target = Pulse.Value(0)

local tweenInfo = TweenInfo.new(
  1, -- Duration in seconds
  Enum.EasingStyle.Quad,
  Enum.EasingDirection.Out
)

local tween = Pulse.Tween(target, tweenInfo)

-- Get the current tween value
print(tween:Get()) -- 0

-- Change the target, the tween animates to it
target:Set(100)
-- tween gradually animates from 0 to 100 over 1 second
```

## Watching Tween Changes

Tweens emit a `Changed` signal as they animate:

```lua
local target = Pulse.Value(0)

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
local tween = Pulse.Tween(target, tweenInfo)

tween.Changed:Connect(function(value)
  print("Tween value:", value)
end)

target:Set(100) -- Prints many times as tween animates
```

## Using with UI

Tweens work great for UI animations:

```lua
local targetSize = Pulse.Value(1)

local tweenInfo = TweenInfo.new(
  0.5, -- 0.5 second animation
  Enum.EasingStyle.Quad,
  Enum.EasingDirection.Out
)

local sizeAnimated = Pulse.Tween(targetSize, tweenInfo)

local frame = Pulse.Create("Frame", {
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
  Size = Pulse.Computed(function()
    return UDim2.new(0, 100 * sizeAnimated:Get(), 0, 100 * sizeAnimated:Get())
  end),
})

targetSize:Set(2) -- Frame smoothly scales over 0.5 seconds
```

## Vector Animations

Tween number values smoothly:

```lua
local targetPos = Pulse.Value(0)

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad)
local positionAnimated = Pulse.Tween(targetPos, tweenInfo)

Pulse.Effect(function()
  workspace.Part.Position = Vector3.new(positionAnimated:Get(), 0, 0)
end)

targetPos:Set(10) -- Part moves over 1 second
```

## Easing Styles

Different easing styles create different feels:

```lua
-- Linear (constant speed)
TweenInfo.new(1, Enum.EasingStyle.Linear)

-- Quad (smooth acceleration)
TweenInfo.new(1, Enum.EasingStyle.Quad)

-- Cubic (smoother acceleration)
TweenInfo.new(1, Enum.EasingStyle.Cubic)

-- Quart, Quint, Sine, Exponential, Circular, Elastic, Back, Bounce
TweenInfo.new(1, Enum.EasingStyle.Elastic)
```

## Easing Directions

Control how the easing applies:

```lua
-- Ease in (slow start)
TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

-- Ease out (slow end)
TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Ease in and out
TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
```

## Configuration Options

```lua
local tweenInfo = TweenInfo.new(
  duration,           -- How long the tween lasts
  easingStyle,        -- EasingStyle enum
  easingDirection,    -- EasingDirection enum
  repeatCount,        -- How many times to repeat (0 = no repeat)
  reverses,           -- Whether to reverse after each repeat
  delayTime           -- Delay before animation starts
)
```

## Complex Animations

Chain tweens with scopes:

```lua
local target = Pulse.Value(0)

local _, scope = Pulse.Scope(function()
  local tween1 = Pulse.Tween(target, TweenInfo.new(1))
  local tween2 = Pulse.Tween(target, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
  
  -- Combine tweens for complex effects
  local combined = Pulse.Computed(function()
    return tween1:Get() + tween2:Get()
  end)
end)
```

## Use Cases

### Fade In/Out

```lua
local opacity = Pulse.Value(0)

local tweenInfo = TweenInfo.new(
  0.5,
  Enum.EasingStyle.Quad,
  Enum.EasingDirection.Out
)

local opacityAnimated = Pulse.Tween(opacity, tweenInfo)

local frame = Pulse.Create("Frame", {
  BackgroundTransparency = Pulse.Computed(function()
    return 1 - opacityAnimated:Get()
  end),
})

opacity:Set(1) -- Fade in over 0.5 seconds
```

### Slide In/Out

```lua
local offset = Pulse.Value(0)

local tweenInfo = TweenInfo.new(
  0.3,
  Enum.EasingStyle.Quad,
  Enum.EasingDirection.InOut
)

local offsetAnimated = Pulse.Tween(offset, tweenInfo)

local panel = Pulse.Create("Frame", {
  Position = Pulse.Computed(function()
    return UDim2.new(0, 100 * offsetAnimated:Get(), 0, 0)
  end),
})

offset:Set(1) -- Slide in over 0.3 seconds
```

### Looping Animation

```lua
local value = Pulse.Value(0)

local tweenInfo = TweenInfo.new(
  1,
  Enum.EasingStyle.Linear,
  Enum.EasingDirection.InOut,
  -1,  -- Repeat forever
  true -- Reverse after each repeat
)

local valueAnimated = Pulse.Tween(value, tweenInfo)

value:Set(1) -- Will loop forever
```

## Tween vs Spring

| Aspect | Tween | Spring |
|--------|-------|--------|
| Duration | Fixed | Variable |
| Animation | Linear/Eased | Physics-based |
| Feel | Predictable | Natural |
| Use case | UI animations, scripted sequences | Responsive, interactive animations |

## Best Practices

- **Use for scripted animations** - Tweens are good for planned animations
- **Combine easing styles** - Experiment to find the right feel
- **Keep durations short** - Most UI animations should be < 1 second
- **Use ease out** - Ease out often feels more responsive
- **Clean up tweens** - Destroy scopes to clean up tweens

## See Also

- [Spring](./spring.md) - Physics-based animations
- [Value](./value.md) - Reactive values
- [Create](./create.md) - UI creation
