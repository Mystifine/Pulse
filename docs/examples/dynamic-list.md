# Dynamic List

A dynamic todo list that demonstrates reactive lists, computed values, and UI manipulation.

## The Complete App

Create a LocalScript in StarterGui:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- App state
local todos = Pulse.Value({})
local inputValue = Pulse.Value("")

-- Create the UI
local screen = Pulse.Create("ScreenGui", {
  Name = "TodoApp",
  Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
})

-- Title
local title = Pulse.Create("TextLabel", {
  Parent = screen,
  Size = UDim2.new(0, 300, 0, 50),
  Position = UDim2.new(0.5, -150, 0, 10),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(50, 50, 50),
  TextColor3 = Color3.fromRGB(255, 255, 255),
  TextScaled = true,
  Text = "Todo List",
})

-- Input frame
local inputFrame = Pulse.Create("Frame", {
  Name = "InputFrame",
  Parent = screen,
  Size = UDim2.new(0, 300, 0, 50),
  Position = UDim2.new(0.5, -150, 0, 70),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(30, 30, 30),
  Children = {
    Pulse.Create("TextBox", {
      Name = "TodoInput",
      Size = UDim2.new(1, -60, 1, 0),
      Position = UDim2.new(0, 0, 0, 0),
      BackgroundColor3 = Color3.fromRGB(50, 50, 50),
      TextColor3 = Color3.fromRGB(255, 255, 255),
      PlaceholderText = "Add a todo...",
      PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
      TextScaled = true,
      Events = {
        FocusLost = function(input)
          inputValue:Set(input.Text)
        end,
      },
    }),
    Pulse.Create("TextButton", {
      Name = "AddButton",
      Size = UDim2.new(0, 50, 1, 0),
      Position = UDim2.new(1, -50, 0, 0),
      AnchorPoint = Vector2.new(1, 0),
      BackgroundColor3 = Color3.fromRGB(0, 150, 0),
      TextColor3 = Color3.fromRGB(255, 255, 255),
      Text = "Add",
      TextScaled = true,
      Events = {
        Activated = function()
          if inputValue:Get() ~= "" then
            local newTodos = table.clone(todos:Get())
            table.insert(newTodos, {
              id = #newTodos + 1,
              text = inputValue:Get(),
              completed = false,
            })
            todos:Set(newTodos)
            inputValue:Set("")
          end
        end,
      },
    }),
  },
})

-- List container
local listContainer = Pulse.Create("ScrollingFrame", {
  Name = "ListContainer",
  Parent = screen,
  Size = UDim2.new(0, 300, 0, 300),
  Position = UDim2.new(0.5, -150, 0, 130),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(20, 20, 20),
  ScrollBarThickness = 10,
  CanvasSize = UDim2.new(0, 0, 0, 0),
  Children = {
    Pulse.ForPairs(todos, function(index, todo)
      return Pulse.Create("Frame", {
        Name = "TodoItem_" .. index,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Children = {
          Pulse.Create("TextButton", {
            Name = "CompleteButton",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 10, 0.5, -15),
            BackgroundColor3 = Pulse.Computed(function()
              return todo.completed and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
            end),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = todo.completed and "✓" or "",
            TextScaled = true,
            Events = {
              Activated = function()
                local updated = table.clone(todos:Get())
                for i, t in ipairs(updated) do
                  if t.id == todo.id then
                    t.completed = not t.completed
                    break
                  end
                end
                todos:Set(updated)
              end,
            },
          }),
          Pulse.Create("TextLabel", {
            Name = "TodoText",
            Size = UDim2.new(1, -100, 1, 0),
            Position = UDim2.new(0, 50, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextScaled = true,
            Text = todo.text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = Pulse.Computed(function()
              return todo.completed and 0.5 or 0
            end),
          }),
          Pulse.Create("TextButton", {
            Name = "DeleteButton",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0.5, -15),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(150, 0, 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Text = "✕",
            TextScaled = true,
            Events = {
              Activated = function()
                local updated = table.clone(todos:Get())
                for i, t in ipairs(updated) do
                  if t.id == todo.id then
                    table.remove(updated, i)
                    break
                  end
                end
                todos:Set(updated)
              end,
            },
          }),
        },
      })
    end),
  },
})

-- Count display
local countDisplay = Pulse.Create("TextLabel", {
  Name = "CountDisplay",
  Parent = screen,
  Size = UDim2.new(0, 300, 0, 40),
  Position = UDim2.new(0.5, -150, 1, -50),
  AnchorPoint = Vector2.new(0.5, 0),
  BackgroundColor3 = Color3.fromRGB(30, 30, 30),
  TextColor3 = Color3.fromRGB(200, 200, 200),
  TextScaled = true,
  Text = Pulse.Computed(function()
    local todoList = todos:Get()
    local total = #todoList
    local completed = 0
    for _, todo in ipairs(todoList) do
      if todo.completed then
        completed = completed + 1
      end
    end
    return string.format("Completed: %d/%d", completed, total)
  end),
})
```

## Key Features

1. **Dynamic List**: Uses `ForPairs` to create todo items dynamically
2. **Reactive State**: Each todo item is a computed button/label that reacts to state
3. **Completion Toggle**: Mark todos as complete with visual feedback
4. **Delete Items**: Remove todos from the list
5. **Computed Statistics**: Shows total and completed count automatically

## How It Works

1. **State Management**: `todos` holds array of todo objects
2. **ForPairs**: Creates one UI item per todo, updates when todos change
3. **Reactive Properties**: Completion button color and text transparency react to completion state
4. **Event Handling**: Buttons update the todos array when clicked
5. **Automatic Updates**: UI updates when todos array changes

## Advanced Features

### Add Edit Capability

```lua
local editingId = Pulse.Value(nil)

Pulse.Create("TextButton", {
  Name = "EditButton",
  -- ... button props ...
  Events = {
    Activated = function()
      editingId:Set(todo.id)
    end,
  },
})
```

### Add Filtering

```lua
local filter = Pulse.Value("all") -- "all", "active", "completed"

local filteredTodos = Pulse.Computed(function()
  local all = todos:Get()
  local f = filter:Get()
  
  if f == "all" then
    return all
  elseif f == "active" then
    return table.create(function(t) return not t.completed end, all)
  else
    return table.create(function(t) return t.completed end, all)
  end
end)
```

### Add Persistence

```lua
-- Save to DataStoreService
local datastore = game:GetService("DataStoreService"):GetDataStore("Todos")

Pulse.Effect(function()
  local success, err = pcall(function()
    datastore:SetAsync(game.Players.LocalPlayer.UserId, todos:Get())
  end)
  if not success then
    warn("Failed to save todos:", err)
  end
end)
```

## Next Steps

- See [Reactive UI](./reactive-ui.md) for more complex examples
- Explore the [API Reference](../api/value.md)
- Read about [Scopes](../api/scope.md) for lifecycle management
