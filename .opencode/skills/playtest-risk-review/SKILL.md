---
name: playtest-risk-review
description: Use this for reviewing scope, player confusion, text fatigue, choice feedback, ending clarity, and v0.1 risk control.
compatibility: opencode
---

## What this skill does

Use this skill before accepting new mechanics or after implementing a playable slice.

## Required documents

Read:
- docs/09_risk_review.md
- docs/10_playtest_checklist.md
- docs/03_vertical_slice.md

## Review dimensions

Always evaluate:
1. Implementation cost in Godot v0.1
2. Does it improve choice feedback?
3. Does it improve station atmosphere?
4. Does it improve the feeling that the system observes the player?
5. Could players feel confused, bored, tricked, or overloaded?
6. Does it expand scope?
7. Is there a lower-cost implementation?

## Output format

Return:
- verdict: adopt / simplify / postpone to v0.2 / reject
- reason
- affected files
- risks
- low-cost alternative
- next concrete task
