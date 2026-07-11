# Reactive UI

A complete example showing how to build a responsive, animated UI with Pulse.

## Dashboard Example

Create a LocalScript in StarterGui:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- App state
local selectedTab = Pulse.Value("dashboard")
local userData = Pulse.Value({
  name = "Player",
  level = 5,
  experience = 450,
  maxExperience = 1000,
})

local stats = Pulse.Value({
  health = 100,
  mana = 50,
  stamina = 75,
})

-- Create main screen
local screen = Pulse.Create("ScreenGui", {
  Name = "Dashboard",
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
})

-- Header
local header = Pulse.Create("Frame", {
  Name = "Header",
  Parent = screen,
  Size = UDim2.new(1, 0, 0, 60),
  BackgroundColor3 = Color3.fromRGB(20, 20, 20),
  BorderSizePixel = 0,
  Children = {
    Pulse.Create("TextLabel", {
      Name = "Title",
      Size = UDim2.new(0.3, 0, 1, 0),
      BackgroundTransparency = 1,
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      Text = Pulse.Computed(function()
        return "Pulse Dashboard - " .. userData:Get().name
      end),
      TextXAlignment = Enum.TextXAlignment.Left,
    }),
  },
})

-- Navigation
local navContainer = Pulse.Create("Frame", {
  Name = "Nav",
  Parent = header,
  Size = UDim2.new(0.7, 0, 1, 0),
  Position = UDim2.new(0.3, 0, 0, 0),
  BackgroundTransparency = 1,
  Children = {
    Pulse.Create("TextButton", {
      Name = "DashboardTab",
      Size = UDim2.new(0.33, 0, 1, 0),
      BackgroundColor3 = Pulse.Computed(function()
        return selectedTab:Get() == "dashboard" and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
      end),
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      Text = "Dashboard",
      BorderSizePixel = 0,
      Events = {
        Activated = function()
          selectedTab:Set("dashboard")
        end,
      },
    }),
    Pulse.Create("TextButton", {
      Name = "StatsTab",
      Size = UDim2.new(0.33, 0, 1, 0),
      Position = UDim2.new(0.33, 0, 0, 0),
      BackgroundColor3 = Pulse.Computed(function()
        return selectedTab:Get() == "stats" and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
      end),
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      Text = "Stats",
      BorderSizePixel = 0,
      Events = {
        Activated = function()
          selectedTab:Set("stats")
        end,
      },
    }),
    Pulse.Create("TextButton", {
      Name = "SettingsTab",
      Size = UDim2.new(0.33, 0, 1, 0),
      Position = UDim2.new(0.66, 0, 0, 0),
      BackgroundColor3 = Pulse.Computed(function()
        return selectedTab:Get() == "settings" and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(30, 30, 30)
      end),
      TextColor3 = Color3.fromRGB(255, 255, 255),
      TextScaled = true,
      Text = "Settings",
      BorderSizePixel = 0,
      Events = {
        Activated = function()
          selectedTab:Set("settings")
        end,
      },
    }),
  },
})

-- Content area
local contentArea = Pulse.Create("Frame", {
  Name = "Content",
  Parent = screen,
  Size = UDim2.new(1, 0, 1, -60),
  Position = UDim2.new(0, 0, 0, 60),
  BackgroundColor3 = Color3.fromRGB(15, 15, 15),
  BorderSizePixel = 0,
})

-- Dashboard tab content
local dashboardTab = Pulse.Create("Frame", {
  Name = "DashboardContent",
  Parent = contentArea,
  Size = UDim2.new(1, 0, 1, 0),
  BackgroundTransparency = 1,
  Visible = Pulse.Computed(function()
    return selectedTab:Get() == "dashboard"
  end),
  Children = {
    -- User card
    Pulse.Create("Frame", {
      Name = "UserCard",
      Size = UDim2.new(0, 300, 0, 150),
      Position = UDim2.new(0, 20, 0, 20),
      BackgroundColor3 = Color3.fromRGB(30, 30, 30),
      BorderSizePixel = 0,
      Children = {
        Pulse.Create("TextLabel", {
          Name = "NameLabel",
          Size = UDim2.new(1, 0, 0, 40),
          BackgroundColor3 = Color3.fromRGB(50, 50, 50),
          TextColor3 = Color3.fromRGB(255, 255, 255),
          TextScaled = true,
          Text = Pulse.Computed(function()
            return userData:Get().name
          end),
        }),
        Pulse.Create("TextLabel", {
          Name = "LevelLabel",
          Size = UDim2.new(1, 0, 0, 30),
          Position = UDim2.new(0, 0, 0, 50),
          BackgroundTransparency = 1,
          TextColor3 = Color3.fromRGB(200, 200, 200),
          TextScaled = true,
          Text = Pulse.Computed(function()
            return "Level: " .. userData:Get().level
          end),
        }),
        Pulse.Create("TextLabel", {
          Name = "ExpLabel",
          Size = UDim2.new(1, 0, 0, 30),
          Position = UDim2.new(0, 0, 0, 85),
          BackgroundTransparency = 1,
          TextColor3 = Color3.fromRGB(200, 200, 200),
          TextScaled = true,
          Text = Pulse.Computed(function()
            local user = userData:Get()
            return string.format("XP: %d/%d", user.experience, user.maxExperience)
          end),
        }),
      },
    }),
  },
})

-- Stats tab content
local statsTab = Pulse.Create("Frame", {
  Name = "StatsContent",
  Parent = contentArea,
  Size = UDim2.new(1, 0, 1, 0),
  BackgroundTransparency = 1,
  Visible = Pulse.Computed(function()
    return selectedTab:Get() == "stats"
  end),
})

-- Create stat bars
local statsList = {
  {name = "Health", key = "health", color = Color3.fromRGB(0, 150, 0)},
  {name = "Mana", key = "mana", color = Color3.fromRGB(0, 100, 255)},
  {name = "Stamina", key = "stamina", color = Color3.fromRGB(255, 150, 0)},
}

for i, stat in ipairs(statsList) do
  local statFrame = Pulse.Create("Frame", {
    Name = stat.name .. "Stat",
    Size = UDim2.new(0, 300, 0, 80),
    Position = UDim2.new(0, 20, 0, 20 + (i - 1) * 100),
    Parent = statsTab,
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Children = {
      Pulse.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Text = stat.name,
      }),
      Pulse.Create("Frame", {
        Name = "BarBg",
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 0,
        Children = {
          Pulse.Create("Frame", {
            Name = "BarFill",
            Size = Pulse.Computed(function()
              local value = stats:Get()[stat.key]
              return UDim2.new(value / 100, 0, 1, 0)
            end),
            BackgroundColor3 = stat.color,
            BorderSizePixel = 0,
          }),
        },
      }),
      Pulse.Create("TextLabel", {
        Name = "ValueLabel",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextScaled = true,
        Text = Pulse.Computed(function()
          return stats:Get()[stat.key] .. "%"
        end),
      }),
    },
  })
end

-- Simulate some stat changes
task.spawn(function()
  while true do
    wait(3)
    local newStats = table.clone(stats:Get())
    newStats.health = math.clamp(newStats.health + math.random(-20, 20), 0, 100)
    newStats.mana = math.clamp(newStats.mana + math.random(-15, 15), 0, 100)
    newStats.stamina = math.clamp(newStats.stamina + math.random(-10, 10), 0, 100)
    stats:Set(newStats)
  end
end)
```

## Key Concepts Demonstrated

1. **Conditional Rendering**: Tabs show/hide based on `selectedTab` state
2. **Reactive Properties**: Button colors and frame visibility update reactively
3. **Computed Displays**: Text updates automatically when state changes
4. **Dynamic Lists**: Multiple stat bars generated from data
5. **Real-time Updates**: Stats change over time, UI updates automatically

## Enhancements

### Add Animations

```lua
local selectedTabAnimated = Pulse.Spring(
  Pulse.Computed(function()
    return selectedTab:Get() == "stats" and 1 or 0
  end),
  {frequency = 3}
)

Visible = Pulse.Computed(function()
  return selectedTabAnimated:Get() > 0
end),
```

### Add Transitions

```lua
local barFillAnimated = Pulse.Spring(
  Pulse.Computed(function()
    return stats:Get()[stat.key] / 100
  end)
)

Size = Pulse.Computed(function()
  return UDim2.new(barFillAnimated:Get(), 0, 1, 0)
end),
```

### Add Sound Effects

```lua
Events = {
  Activated = function()
    selectedTab:Set("stats")
    game:GetService("SoundService"):PlayLocalSound(clickSound)
  end,
}
```

## Next Steps

- Explore [Scopes](../api/scope.md) for component lifecycle management
- Learn about [Animations](../api/spring.md) for smooth effects
- Check the [API Reference](../api/value.md) for all available functions
