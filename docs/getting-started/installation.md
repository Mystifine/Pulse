# Installation

## Using Wally

The recommended way to add Pulse to your project is using [Wally](https://wally.run).

Add Pulse to your `wally.toml`:

```toml
[dependencies]
Pulse = "mystifine/pulse@0.1.0"
```

Then run:

```bash
wally install
```

## Manual Installation

1. Clone the [Pulse repository](https://github.com/Mystifine/Pulse)
2. Copy the `src` folder to your project
3. Include it in your Rojo project configuration

### Rojo Configuration

In your `default.project.json`:

```json
{
  "name": "MyProject",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "Pulse": {
        "$path": "path/to/Pulse/src"
      }
    }
  }
}
```

## Verifying Installation

Create a simple test script to verify Pulse is working:

```lua
local Pulse = require(game.ReplicatedStorage.Pulse)

local value = Pulse.Value(42)
print(value:Get()) -- Should print: 42
```

## Next Steps

- Read [Basic Concepts](./basic-concepts.md) to understand how Pulse works
- Follow the [Quick Start](./quickstart.md) guide
- Check out the [Examples](../examples/counter.md)
