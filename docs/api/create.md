# Create

Create UI elements declaratively with automatic property binding to reactive values.

## Basic Usage

```lua
local screen = Pulse.Create("ScreenGui", {
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
})

local label = Pulse.Create("TextLabel", {
  Parent = screen,
  Text = "Hello, World!",
  Size = UDim2.new(0, 100, 0, 50),
})
```

## Reactive Properties

Bind reactive values to properties:

```lua
local count = Pulse.Value(0)

local label = Pulse.Create("TextLabel", {
  Parent = screen,
  -- Bind a Computed value to the Text property
  Text = Pulse.Computed(function()
    return "Count: " .. count:Get()
  end),
})

count:Set(5) -- Label automatically updates
```

## Events

Handle UI events:

```lua
local count = Pulse.Value(0)

local button = Pulse.Create("TextButton", {
  Parent = screen,
  Text = "Click me",
  Events = {
    -- Button events are specified as a table
    Activated = function(button)
      count:Set(count:Get() + 1)
    end,
    MouseEnter = function(button)
      button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    end,
    MouseLeave = function(button)
      button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end,
  },
})
```

## Children

Add children declaratively:

```lua
local container = Pulse.Create("Frame", {
  Parent = screen,
  Size = UDim2.new(0, 200, 0, 200),
  Children = {
    Pulse.Create("TextLabel", {
      Text = "Child 1",
    }),
    Pulse.Create("TextLabel", {
      Text = "Child 2",
    }),
  },
})
```

## Reactive Children

Use reactive values for dynamic children:

```lua
local items = Pulse.Value({})

local list = Pulse.Create("Frame", {
  Parent = screen,
  Children = {
    Pulse.Computed(function()
      -- Return a table of child instances
      local children = {}
      for i, item in ipairs(items:Get()) do
        table.insert(children, Pulse.Create("TextLabel", {
          Text = item,
        }))
      end
      return children
    end),
  },
})

items:Set({{"Item 1", "Item 2", "Item 3"}}) -- Children update automatically
```

## ForPairs Helper

Create dynamic lists easily:

```lua
local items = Pulse.Value({
  apple = "An apple",
  banana = "A banana",
  cherry = "A cherry",
})

local list = Pulse.ForPairs(items, function(key, value)
  return Pulse.Create("TextLabel", {
    Text = value,
  })
end)

items:Set({apple = "An apple", banana = "A banana"}) -- List updates automatically
```

## Custom UI Components

Create reusable components:

```lua
local function createButton(text, onClick)
  return Pulse.Create("TextButton", {
    Text = text,
    Size = UDim2.new(0, 100, 0, 50),
    BackgroundColor3 = Color3.fromRGB(0, 100, 255),
    Events = {
      Activated = onClick,
    },
  })
end

local button = createButton("Click me", function()
  print("Button clicked!")
end)
```

## Reactive Components

Create components that react to state:

```lua
local count = Pulse.Value(0)

local function createCounter()
  return Pulse.Scope(function()
    local container = Pulse.Create("Frame", {
      Parent = screen,
      Children = {
        Pulse.Create("TextLabel", {
          Text = Pulse.Computed(function()
            return "Count: " .. count:Get()
          end),
        }),
        Pulse.Create("TextButton", {
          Text = "Increment",
          Events = {
            Activated = function()
              count:Set(count:Get() + 1)
            end,
          },
        }),
      },
    })
    
    return container
  end)
end

local results, counterScope = createCounter()
```

## Properties with Reactive Values

All standard Roblox properties work:

```lua
local isVisible = Pulse.Value(true)

local frame = Pulse.Create("Frame", {
  Visible = isVisible,  -- Automatically updates when isVisible changes
  BackgroundColor3 = Color3.fromRGB(255, 0, 0),
  BackgroundTransparency = 0.5,
  Size = UDim2.new(0, 100, 0, 100),
  Position = UDim2.new(0, 50, 0, 50),
})

isVisible:Set(false) -- frame becomes invisible
```

## Advanced: Custom Functions

Pass a function to create custom UI:

```lua
local component = Pulse.Create(function(props)
  local container = Instance.new("Frame")
  
  -- Access props passed to Create
  for key, value in props do
    container[key] = value
  end
  
  return container
end, {
  Parent = screen,
  Size = UDim2.new(0, 100, 0, 100),
})
```

## Type Support

Create supports any Roblox Instance type:

```lua
Pulse.Create("ScreenGui", {...})
Pulse.Create("Frame", {...})
Pulse.Create("TextLabel", {...})
Pulse.Create("TextButton", {...})
Pulse.Create("ImageLabel", {...})
Pulse.Create("ScrollingFrame", {...})
-- And any other GUI class
```

## Best Practices

- **Use Computed for derived UI** - Bind computed values to properties
- **Keep components small** - Break complex UI into smaller components
- **Use scopes** - Use Pulse.Scope to manage component lifecycle
- **Handle events cleanly** - Put event handlers in the Events table
- **Clean up when done** - Destroy scopes to clean up UI

## Use Cases

### Form Input

```lua
local name = Pulse.Value("")
local email = Pulse.Value("")

local form = Pulse.Create("Frame", {
  Children = {
    Pulse.Create("TextBox", {
      PlaceholderText = "Name",
      Events = {
        FocusLost = function(input)
          name:Set(input.Text)
        end,
      },
    }),
    Pulse.Create("TextBox", {
      PlaceholderText = "Email",
      Events = {
        FocusLost = function(input)
          email:Set(input.Text)
        end,
      },
    }),
  },
})
```

### Dynamic Grid

```lua
local items = Pulse.Value({})

local grid = Pulse.Create("ScrollingFrame", {
  UIGridLayout = {
    FillDirection = Enum.FillDirection.Horizontal,
    CellSize = UDim2.new(0, 100, 0, 100),
  },
  Children = {
    Pulse.ForPairs(items, function(key, item)
      return Pulse.Create("TextLabel", {
        Text = item,
        Size = UDim2.new(0, 100, 0, 100),
      })
    end),
  },
})
```

## See Also

- [Value](./value.md) - Reactive values
- [Computed](./computed.md) - Derived values
- [Effect](./effect.md) - Side effects
- [Scope](./scope.md) - Lifecycle management
- [Spring](./spring.md) - Animations
- [Tween](./tween.md) - Animations
