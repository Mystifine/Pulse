# Pulse

Pulse is a Roblox place and codebase managed with Rojo. The repository stores Luau source in a Rojo-compatible project layout so development can be done locally and synchronized with Roblox Studio.

This README covers a brief overview, prerequisites, common workflows for building and developing, and guidance for contributing.

## Features
- Source-first Roblox project layout (managed with Rojo)
- Local development workflow that syncs code to Roblox Studio
- Simple build command to produce a .rbxlx place file for distribution or testing

## Prerequisites
- Roblox Studio (for running and testing the place)
- Rojo (recommended v7.x or newer) — https://rojo.space
- Git (optional, for source control)

## Quick start
Build the place file from the source and open it in Roblox Studio:

```bash
rojo build -o "Pulse.rbxlx"
```

To enable live-sync while developing, start the Rojo server and open the place in Roblox Studio:

```bash
rojo serve
```

With `rojo serve` running, edits made in the local source tree will be synchronized into the running Studio session.

## Development workflow
1. Open the project in your editor and edit the Luau source (typically under `src/` in a Rojo project).
2. Run `rojo serve` and have Roblox Studio attach to the running project to see changes live.
3. When ready to produce a distributable place file, run `rojo build -o "Pulse.rbxlx"` and open the generated file in Studio for final testing.

Notes:
- Keep the Rojo project configuration (e.g. `default.project.json` or `default.project`) up to date with your source layout so files map correctly into the Studio hierarchy.
- Use Studio's play-testing to verify runtime behavior and debug scripts.

## Repository layout (typical)
- src/ — Luau source files and module scripts (Rojo-managed)
- default.project.json — Rojo project configuration (maps `src/` into the Roblox place)
- Pulse.rbxlx — generated place file (produced by `rojo build`)

If your repo differs, follow the Rojo project file present in this repository.

## Contributing
Contributions, bug reports, and pull requests are welcome. Recommended workflow:
1. Fork the repository
2. Create a branch for your change
3. Run and test your changes locally with `rojo serve` and Roblox Studio
4. Open a pull request with a description of the change and any testing notes

## Troubleshooting
- If Rojo cannot find your project file, ensure `default.project.json` exists in the repository root and the paths inside it point to the correct source directories.
- If changes are not appearing in Studio while `rojo serve` is running, restart the Rojo server and re-open the place in Studio.

## Further reading
- Rojo documentation: https://rojo.space/docs
- Roblox Developer Hub: https://developer.roblox.com

## License
Specify a license for this project by adding a LICENSE file to the repository.
