---
description: Review Godot scene/script architecture for scope, bugs, and maintainability.
agent: godot-architect
---

Review the current Godot implementation.

Focus on:
- scene/script responsibilities
- GameState correctness
- signal wiring
- JSON loading
- UI flow
- accidental scope expansion
- likely Godot runtime errors

Do not edit files unless I explicitly ask.

Return:
1. Critical issues
2. Important but non-blocking issues
3. Suggested next fixes
4. Files to inspect manually in Godot editor
