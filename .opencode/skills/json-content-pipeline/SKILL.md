---
name: json-content-pipeline
description: Use this when creating, editing, validating, or refactoring JSON files for calibration questions, story nodes, interactables, and endings.
compatibility: opencode
---

## What this skill does

Use this skill for:
- data/calibration_questions.json
- data/story_nodes.json
- data/interactables.json
- data/endings.json

## Required documents

Read:
- docs/04_system_design.md
- docs/07_content_data_spec.md

## JSON rules

- Keep valid JSON.
- No comments inside JSON.
- Every story node must have node_id, stage, visible_text, options, world_changes, set_flags.
- Every option must have id, text, state_delta, set_flags, world_changes, next_node.
- Use only these state keys unless docs are updated:
  - doubt
  - control
  - obedience
  - anomaly
- Investigation clicks should set flags, not farm state repeatedly.
- Keep node IDs stable and readable.
- Do not create branching explosion.
- Prefer five station rounds and three ending directions.

## Validation checklist

After editing JSON:
1. Check syntax.
2. Check all next_node targets exist.
3. Check all state_delta keys are valid.
4. Check every round has 3–4 options.
5. Check world_changes only uses known station objects:
   - notice_board
   - clock
   - broadcast_light
   - exit_gate
6. Check endings can actually be reached from state rules.
