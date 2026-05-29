---
name: godot-4-ui-prototype
description: Use this for Godot 4.x Control UI implementation, GDScript scene wiring, signals, JSON loading, and low-fidelity prototype work for this project.
compatibility: opencode
---

## What this skill does

Use this skill when implementing or modifying Godot scenes, Control UI, GDScript scripts, signals, scene switching, JSON loading, or simple visual feedback.

## Project constraints

- Godot 4.x only
- GDScript only
- Control UI first
- No C#
- No 3D
- No complex movement
- No combat
- No inventory
- No real AI API in v0.1

## Required workflow

Before editing:
1. Read AGENTS.md.
2. Read docs/04_system_design.md.
3. Read docs/05_godot_implementation.md.
4. If content data is involved, also read docs/07_content_data_spec.md.

Implementation rules:
1. Keep changes small and focused.
2. Prefer existing scene/script structure.
3. Use signals for UI button events.
4. Keep GameState as the source of truth.
5. Keep narrative content in JSON where possible.
6. Do not hardcode long story text inside scripts unless it is a temporary placeholder.
7. Do not add plugins unless explicitly requested.

Verification:
- Check that Godot opens the project.
- Check that clicking buttons updates visible text.
- Check that GameState changes after choices.
- Check that investigation popups do not repeatedly farm state.
- Check that the player can reach a complete flow from calibration to ending.
