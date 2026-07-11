# Counter App

A simple counter app to demonstrate the basics of Pulse.

## The Complete App

Create a LocalScript in StarterGui:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- Create reactive state
local count = Pulse.Value(0)

-- Create the UI
local screen = Pulse.Create("ScreenGui", {
  Name = "CounterApp",
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
})

-- Title
local title = Pulse.Create("TextLabel", {
  Name = "Title",
  Parent = screen,
  Size = UDim2.new(0, 200, 0, 50),
  Position = UDim2.new(0.5, -100, 0, 20),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(50, 50, 50),
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  Text = "Counter",
})

-- Display count
local countLabel = Pulse.Create("TextLabel", {
  Name = "CountLabel",
  Parent = screen,
  Size = UDim2.new(0, 200, 0, 100),
  Position = UDim2.new(0.5, -100, 0, 100),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(30, 30, 30),
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  Text = Pulse.Computed(function()
    return tostring(count:Get())
  end),
})

-- Increment button
local incrementBtn = Pulse.Create("TextButton", {
  Name = "IncrementButton",
  Parent = screen,
  Size = UDim2.new(0, 90, 0, 50),
  Position = UDim2.new(0.5, -140, 0, 220),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(0, 150, 0),
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  Text = "+1",
  Events = {
    Activated = function()
      count:Set(count:Get() + 1)
    end,
  },
})

-- Decrement button
local decrementBtn = Pulse.Create("TextButton", {
  Name = "DecrementButton",
  Parent = screen,
  Size = UDim2.new(0, 90, 0, 50),
  Position = UDim2.new(0.5, 50, 0, 220),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(150, 0, 0),
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  Text = "-1",
  Events = {
    Activated = function()
      count:Set(count:Get() - 1)
    end,
  },
})

-- Reset button
local resetBtn = Pulse.Create("TextButton", {
  Name = "ResetButton",
  Parent = screen,
  Size = UDim2.new(0, 200, 0, 50),
  Position = UDim2.new(0.5, -100, 0, 290),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(100, 100, 100),
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  Text = "Reset",
  Events = {
    Activated = function()
      count:Set(0)
    end,
  },
})

-- Display status
local status = Pulse.Create("TextLabel", {
  Name = "Status",
  Parent = screen,
  Size = UDim2.new(0, 300, 0, 40),
  Position = UDim2.new(0.5, -150, 1, -60),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(30, 30, 30),
  TextColor3 = Color3.fromRGB(200, 200, 200),
  TextScaled = true,
  Text = Pulse.Computed(function()
    local c = count:Get()
    if c > 0 then
      return "Count is positive"
    elseif c < 0 then
      return "Count is negative"
    else
      return "Count is zero"
    end
  end),
})
```

## How It Works

1. **State**: `count` holds the current value
2. **UI Creation**: All UI elements are created with `Pulse.Create`
3. **Reactive Binding**: The count label's text is bound to a computed value that converts the count to a string
4. **Event Handling**: Buttons update the count when clicked
5. **Reactive Status**: The status label reactively shows whether the count is positive, negative, or zero

## Key Concepts

- **Pulse.Value** - Holds mutable state
- **Pulse.Computed** - Derives text from the count
- **Pulse.Create** - Creates UI elements with reactive properties
- **Events** - Button clicks update state

## Extensions

Try these extensions:

1. **Add maximum/minimum limits**
   ```lua
   Events = {
     Activated = function()
       local newCount = count:Get() + 1
       if newCount <= 10 then
         count:Set(newCount)
       end
     end,
   }
   ```

2. **Add animation**
   ```lua
   local countAnimated = Pulse.Spring(count, {frequency = 3})
   
   Text = Pulse.Computed(function()
     return tostring(math.floor(countAnimated:Get()))
   end),
   ```

3. **Add keyboard shortcuts**
   ```lua
   game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
     if gameProcessed then return end
     
     if input.KeyCode == Enum.KeyCode.Up then
       count:Set(count:Get() + 1)
     elseif input.KeyCode == Enum.KeyCode.Down then
       count:Set(count:Get() - 1)
     end
   end)
   ```

## Next Steps

- See [Dynamic List](./dynamic-list.md) for a more complex example
- Explore the [API Reference](../api/value.md)
- Read [Basic Concepts](../getting-started/basic-concepts.md)
