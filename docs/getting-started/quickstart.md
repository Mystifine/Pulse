# Quick Start

Let's build a simple reactive counter app to see Pulse in action.

## Setup

First, make sure you've installed Pulse. See [Installation](./installation.md) if you haven't already.

## Build a Counter

Create a new LocalScript in StarterGui with the following code:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- Create reactive state
local count = Pulse.Value(0)

-- Create a computed value
local isEven = Pulse.Computed(function()
  return count:Get() % 2 == 0
end)

-- Create an effect that updates UI
Pulse.Effect(function()
  print("Count:", count:Get())
  print("Is Even:", isEven:Get())
end)

-- Simulate some user interactions
wait(1)
count:Set(1)
wait(1)
count:Set(2)
wait(1)
count:Set(3)
```

When you run this script, you should see:

```
Count: 0
Is Even: true
Count: 1
Is Even: false
Count: 2
Is Even: true
Count: 3
Is Even: false
```

## Add UI

Now let's create some actual UI. Create a ScreenGui with TextLabels to display the counter:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- Create reactive state
local count = Pulse.Value(0)

-- Create the UI using Pulse.Create
local screen = Pulse.Create("ScreenGui", {
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
})

local countLabel = Pulse.Create("TextLabel", {
  Parent = screen,
  Size = UDim2.new(0, 100, 0, 50),
  Position = UDim2.new(0, 50, 0, 50),
  BackgroundColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  -- Bind the Text property to the reactive value
  Text = Pulse.Computed(function()
    return "Count: " .. count:Get()
  end),
})

local incrementButton = Pulse.Create("TextButton", {
  Parent = screen,
  Size = UDim2.new(0, 100, 0, 50),
  Position = UDim2.new(0, 50, 0, 120),
  BackgroundColor3 = Color3.fromRGB(0, 100, 255),
  Text = "Increment",
  TextScaled = true,
  Events = {
    Activated = function()
      count:Set(count:Get() + 1)
    end,
  },
})

local decrementButton = Pulse.Create("TextButton", {
  Parent = screen,
  Size = UDim2.new(0, 100, 0, 50),
  Position = UDim2.new(0, 160, 0, 120),
  BackgroundColor3 = Color3.fromRGB(255, 0, 0),
  Text = "Decrement",
  TextScaled = true,
  Events = {
    Activated = function()
      count:Set(count:Get() - 1)
    end,
  },
})
```

Now you have a fully functional counter! Click the buttons to increment and decrement the count.

## Key Concepts Used

- **Reactive Values**: `count` holds the state
- **Computed Values**: `Computed` function derives the text from the count
- **UI Creation**: `Pulse.Create` binds reactive values to UI elements
- **Event Handling**: Button clicks update the reactive state

## Next Steps

- Read [Basic Concepts](./basic-concepts.md) to understand how everything works
- Explore the [API Reference](../api/value.md) for more functionality
- Check out more [Examples](../examples/dynamic-list.md)

## Tips

- Always wrap UI creation in LocalScripts that run on the client
- Use `Pulse.Create` with computed values for dynamic text
- Handle events in the `Events` table to update reactive state
- Use `Pulse.Scope` to manage cleanup when UI is destroyed
