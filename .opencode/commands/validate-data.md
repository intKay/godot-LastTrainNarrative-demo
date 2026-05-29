---
description: Validate JSON content graph and state logic.
agent: data-integrity-reviewer
---

Validate all JSON files under data/.

Check:
- JSON syntax
- required fields
- next_node links
- state_delta keys
- flags
- world_changes
- ending reachability
- repeated-click farming risk
- mismatch with docs/07_content_data_spec.md

If safe, propose minimal fixes.
