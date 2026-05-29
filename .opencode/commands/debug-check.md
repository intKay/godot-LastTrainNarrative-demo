---
description: 全栈静态验证——JSON 解析、状态机链路、结局路径、GameState.reset、节点路径
---

不做 Godot 实机运行。只做静态验证。先读取 docs/102 §19（测试要求）和 AGENTS.md「验证方式」节。

## 1. JSON 解析验证
用 bash 逐个验证所有 data/*.json 是否合法：
```
python3 -c "import json; json.load(open('data/calibration_questions.json'))" && echo PASS || echo FAIL
python3 -c "import json; json.load(open('data/story_nodes.json'))" && echo PASS || echo FAIL
python3 -c "import json; json.load(open('data/interactables.json'))" && echo PASS || echo FAIL
python3 -c "import json; json.load(open('data/endings.json'))" && echo PASS || echo FAIL
```

## 2. GameState.reset 完整性
读取 `scripts/game_state.gd`，列出 `reset()` 中清理的字段。对照文件开头 `var` 声明列表，检查是否每个字段都在 `reset()` 中被清零。特别检查 v0.2 新增字段（dominant_trait、ai_*、audio_enabled）是否也被清零。

## 3. story node 链路完整性
解析 `data/story_nodes.json`，验证链路：
- `station_intro` → 选项的 next_node → `station_round_1` 存在
- `station_round_1` → 选项的 next_node → `station_round_2` 存在
- `station_round_2` → 选项的 next_node → `station_round_3` 存在
- `station_round_3` → 选项的 next_node → 结局触发

## 4. 结局路径模拟
根据 endings.json 和 ending_screen.gd 的结局判断逻辑（doubt/control/obedience 最高维度），模拟三条路径：
- obedience 最高：确认可触发 obedience_ending
- control 最高：确认可触发 control_ending
- doubt 最高：确认可触发 doubt_ending
- 平局时默认 doubt_ending 仍可触发

## 5. 节点路径一致性
读取 `scenes/station_scene.tscn`，提取所有 node name 和层级路径，与 `station_scene.gd` 中的 `$RootMargin/VBox/...` @onready 声明逐项对比。

## 6. 代码约束检查
- grep 检查：主线按钮 handler 是否都有 `_disable_choices()` 调用
- grep 检查：调查物 handler 是否只改 `GameState.flags` 和 `story_label.text`，不直接改 doubt/control/obedience/anomaly
- grep 检查：是否有 `Label` 节点的 `pressed` 连接（误用 Label 当 Button）

## 7. 禁词扫描
grep 所有 data/*.json 和 scripts/*.gd 中的文本部分，检查是否出现禁词：列车员 / 乘客 / 怪物 / 真实城市 / 车厢 / 站外 / 隐藏房间 / 逃脱 / 第四结局

## 输出格式

```
调试验证报告

1. JSON 解析：全部通过 / 失败文件列表
2. GameState.reset：通过 / 缺失字段列表
3. Story 链路：通过 / 断裂位置
4. 结局路径：三条均可触发 / 无法触发列表
5. 节点路径：一致 / 不匹配列表
6. 代码约束：通过 / 违规位置
7. 禁词扫描：通过 / 出现位置

总评：全部通过 / 有 x 项需修复
Godot F5 实机运行：未运行 / 已运行（结果）
```
