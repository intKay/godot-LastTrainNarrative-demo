# 叙事校准程序 / 末班车站

Godot 4.6 + GDScript + Control UI + JSON 数据驱动互动叙事原型。一分钟切片已完成，当前扩展 v0.1 完整低保真原型（3～5 分钟）。

## 运行方式

- F5 运行，入口 `calibration_screen.tscn` → `station_scene.tscn`
- Autoload: `GameState`（`scripts/game_state.gd`）

## 核心状态

- `doubt` / `control` / `obedience` / `anomaly` + `flags` + `choice_history`
- `initial_world_hint`：校准选择决定公告屏提示文本
- `last_choice_label`：上一轮选择的标签，用于公告屏残影

## 数据管线

- `data/*.json` → `DataLoader.load_json()` → UI
- 新增内容优先改 JSON，不改核心脚本

## Godot 规则

- 可点击必须用 `Button`，勿用 `Label`
- 主线按钮点击后立即 `disabled = true`，防重复刷状态
- 公告屏调查只改文本或 flag，不改 `doubt/control/obedience/anomaly`
- 节点路径必须与 `.tscn` 实际结构一致

## 范围审计

新增功能前自检：

1. 是否增强"系统正在观察玩家选择"？
2. 是否超出 v0.1 范围（3 轮 / 3 问 / 4 物 / 3 结局）？
3. 是否引入复杂系统（真实 AI / 多 NPC / 移动 / 网络）？
4. 是否增加玩家困惑或等待？
5. 功能不服务于核心体验则延后。

## 禁止事项

- 不接真实 AI API，不自由输入
- 不做多 NPC、战斗、背包、复杂谜题、2D 移动
- 不做动态音乐、联网、Web / 手机适配
- 不做超过 3 轮的车站选择
- 不一次性完整实现 v0.1（分阶段逐步扩展）
- 不经确认修改 `project.godot` 的 Autoload

## Git 约定

- 修改完成并测试验证后，必须将改动写入 `docs/*.md`
- 提交信息须包含阶段号和目的
- 不保留 API key / token / provider credentials
