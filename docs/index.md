# Pulse

A powerful and intuitive reactive library for Roblox that enables declarative, functional UI development with automatic dependency tracking.
!!! warning "AI-Assisted Documentation"
    Documentation is AI-Assisted and may contain inaccuracies. Please report any issues or suggestions on the [GitHub Issues Page](https://github.com/Mystifine/Pulse/issues).
## Features

- **Reactive Values** - Create dynamic values that automatically notify dependents of changes
- **Computed Values** - Define values that reactively compute based on other values
- **Effects** - Run side effects whenever reactive dependencies change
- **Scopes** - Manage cleanup and lifecycle of reactive objects
- **Animations** - Built-in Spring and Tween animations with reactive support
- **UI Creation** - Declarative UI creation with automatic property binding
- **Type Safe** - Full Luau type annotations for IDE support

## Quick Example

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

-- Create reactive values
local count = Pulse.Value(0)
local doubled = Pulse.Computed(function()
  return count:Get() * 2
end)

-- Create an effect that runs when dependencies change
Pulse.Effect(function()
  print("Count is now:", count:Get())
  print("Doubled is:", doubled:Get())
end)

-- Update the value
count:Set(5) -- Prints: "Count is now: 5" and "Doubled is: 10"
```

## Core Concepts

### Reactivity
Pulse uses a reactive graph to track dependencies automatically. When a value changes, all dependent computations and effects are updated efficiently.

### Declarative UI
Create UI elements declaratively with automatic property binding to reactive values. Changes propagate automatically without manual updates.

### Scopes
Scopes manage the lifecycle of reactive objects. Use scopes to group related effects and computations for easy cleanup.

## Getting Started

- **[Installation](./getting-started/installation.md)** - Add Pulse to your project
- **[Basic Concepts](./getting-started/basic-concepts.md)** - Understand reactivity and scopes
- **[Quick Start](./getting-started/quickstart.md)** - Build your first reactive app

## Documentation

- **[API Reference](./api/value.md)** - Complete API documentation
- **[Examples](./examples/counter.md)** - Real-world usage examples

## Contributing

We welcome contributions! See [Contributing](./contributing/contributing.md) for guidelines.

## License

Pulse is licensed under the MIT License. See [License](./about/license.md) for details.
