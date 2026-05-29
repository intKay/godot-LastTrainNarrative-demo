# 叙事校准程序 / 末班车站

Godot 4.6 + GDScript + Control UI + JSON 数据驱动互动叙事原型。当前进入 v0.2，目标是 5-8 分钟外部试玩增强版。

## 必读顺序

- v0.2 开发前先读 `docs/101_v0_2_requirement_spec.md` 和 `docs/102_v0_2_opencode_execution_constraints.md`。
- `docs/102_v0_2_opencode_execution_constraints.md` 是范围约束最高优先级；临时想法与其冲突时，以 docs/102 为准。
- `opencode.json` 已加载 `AGENTS.md` 和 `docs/*.md`，不要把长需求全文复制到本文件。

## 运行入口

- 用 Godot 打开 `project.godot`，按 F5 运行。
- `project.godot` 当前入口是 `res://scenes/calibration_screen.tscn`。
- Autoload 只有 `GameState="*res://scripts/game_state.gd"`；未经用户明确批准，不要改 Autoload。

## 核心数据流

- `scripts/data_loader.gd` 只负责读取 JSON。
- `scripts/calibration_screen.gd` 读取 `data/calibration_questions.json`。
- `scripts/station_scene.gd` 读取 `data/story_nodes.json` 和 `data/interactables.json`。
- `scripts/ending_screen.gd` 读取 `data/endings.json`。
- 新剧情、调查文本、结局文本优先改 `data/*.json`；不要为了小需求建立复杂配置系统。

## 关键状态规则

- 主状态：`doubt` / `control` / `obedience` / `anomaly`。
- `anomaly` 是叙事噪声/系统失真值，不是第四结局路线。
- v0.2 可新增 `dominant_trait`、AI 相关字段和 `audio_enabled`，但必须在 `GameState.reset()` 中清零。
- 不要改变现有字段含义：`doubt`、`control`、`obedience`、`anomaly`、`flags`、`choice_history`、`last_choice_label`、`initial_world_hint`、`current_node_id`。

## StationScene 约束

- 当前 `station_scene.gd` 状态机是 `INTRO -> INVESTIGATED -> FINISHED -> END`。
- 主线按钮点击后必须禁用，避免重复刷状态。
- 调查物点击只显示文本/设置 flag，不直接修改 `doubt/control/obedience/anomaly`。
- 可点击交互必须用 `Button`，不要用 `Label` 伪装按钮。
- 修改 `scenes/station_scene.tscn` 时，同步检查 `station_scene.gd` 的 `$RootMargin/VBox/...` 节点路径。
- `_show_continue()` 和 `_show_ending_trigger()` 会改 `choice_a.pressed` 连接，新增流程时避免重复连接或遗留旧 handler。

## v0.2 阶段边界

- 必须按阶段推进：v0.2-1 引导与设备基础，v0.2-2 车站反馈，v0.2-3 入场/刷新动效，v0.2-4 音效，v0.2-5 Mock AI，v0.2-6 测试准备。
- 每阶段只做本阶段目标；不要在做 UI 时顺手改结局算法，不要在做引导时顺手接 API。
- 每阶段完成后写对应报告：`docs/111_v0_2_1_guidance_devices_report.md` 到 `docs/116_v0_2_6_playtest_ready_report.md`。
- 报告必须说明修改清单、是否改核心逻辑、静态测试结果、Godot F5 是否实际运行、风险和回滚建议。

## AI 模型优化提醒

每完成一个 v0.2 阶段并生成报告后，提醒用户参考 `docs/103_ai_model_selection_guide.md` 进行多模型优化。

核心原则：
- 文本评审 → Kimi K2.6（中文最佳性价比）
- 代码/逻辑/JSON 验证 → DeepSeek V4 Free（免费日常主力）
- 阶段交付前全栈审核 → GPT-5.5（一阶段只用一次）
- 不要混跑同一任务

## v0.2 禁止事项

- 不新增第四轮主线、第四结局、自由输入、NPC、战斗、背包、复杂地图、复杂谜题。
- 不让 AI 决定 `state_delta`、`next_node`、`ending_id`、选项数量或场景物件。
- API 只能是实验开关，不能成为默认运行依赖。
- 不写入真实 API key、token 或 credentials。
- 不引入未授权音频/美术素材、复杂 Shader、复杂插件或联网发布功能。
- 不要声称 "Godot F5 已通过"，除非本环境或用户实际运行过。

## 验证方式

- 当前仓库没有 CI、包管理 manifest、测试 runner 或 lint/typecheck 配置。
- 能运行 Godot 时，用 F5 验证完整路径。
- 不能运行 Godot 时，做静态验证：JSON 可解析、节点路径匹配、三条结局路径不退化、`GameState.reset()` 清理新增字段。
- 如果没有实机运行，最终说明中必须写明 "未运行 Godot F5"。

## Git 工作流

- 只在完成一轮 playtest 并确认无误后 commit，不要在开发中途随意提交。
- 提交前运行 `/playtest-check` 查看 F5 测试清单，按清单验证通过后 commit。
- 执行：`git add -A && git commit -m "简短说明" && git push`
- 不要回滚用户或其他 Agent 的改动。
