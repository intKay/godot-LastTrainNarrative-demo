# 叙事校准程序 / 末班车站

Godot 4.6 + GDScript + Control UI + JSON 数据驱动互动叙事原型。v0.2 增强版原型（5～8 分钟可外部试玩）。

> **v0.2 开发前必须首先阅读：**
> - `docs/101_v0_2_requirement_spec.md`（需求规格）
> - `docs/102_v0_2_opencode_execution_constraints.md`（执行约束）
> - 本文档范围约束优先级低于 docs/102
> - 遇到矛盾时以 docs/102 为准

## 项目结构

```
├── data/                    # JSON 数据文件
│   ├── calibration_questions.json  # 校准问题
│   ├── story_nodes.json            # 故事节点
│   ├── interactables.json          # 调查元素
│   └── endings.json                # 结局
├── scenes/                  # Godot 场景
│   ├── calibration_screen.tscn     # 校准界面（入口）
│   ├── station_scene.tscn          # 车站主场景
│   ├── ending_screen.tscn          # 结局画面
│   └── main_test.tscn              # 测试场景
├── scripts/                 # GDScript
│   ├── game_state.gd               # Autoload 状态管理
│   ├── data_loader.gd              # JSON 加载器
│   ├── calibration_screen.gd       # 校准逻辑
│   ├── station_scene.gd            # 车站逻辑
│   └── ending_screen.gd            # 结局逻辑
├── docs/*.md                # 设计文档与阶段报告
├── .opencode/               # OpenCode 配置
├── project.godot            # Godot 工程文件
└── opencode.json            # OpenCode 配置
```

## 运行方式

- F5 运行，入口 `calibration_screen.tscn` → `station_scene.tscn`
- Autoload: `GameState`（`scripts/game_state.gd`）

## 核心状态

- `doubt` / `control` / `obedience` / `anomaly` + `flags` + `choice_history`
- `initial_world_hint`：校准选择决定公告屏提示文本
- `last_choice_label`：上一轮选择的标签，用于公告屏残影

## v0.2 新增状态

- `dominant_trait`：`"doubt"` | `"control"` | `"obedience"` | `"mixed"`
- `ai_session_id` / `ai_guidance_used` / `ai_rewritten_option_slot` / `ai_rewritten_option_text`
- `audio_enabled`

## 数据管线

- `data/*.json` → `DataLoader.load_json()` → UI
- 新增内容优先改 JSON，不改核心脚本

## 当前进度

v0.1 已完成（阶段 0 → 2.8）。
当前 v0.2 规划阶段，6 个实施阶段待开发：

- v0.2-1：引导与设备基础
- v0.2-2：车站空间反馈增强
- v0.2-3：生成式入场与刷新动效
- v0.2-4：音效与环境音
- v0.2-5：Mock AI 动态引导与选项改写
- v0.2-6：完整测试与试玩准备

## 自动提交规则

每次修改完成后，必须立即执行：

```bash
git add -A
git commit -m "简短说明"
git push
```

不需要等待用户提示，自行执行。

## v0.2 禁止事项

- 新增第四轮主线 / 第四结局 / 自由输入 / NPC / 战斗 / 背包 / 复杂地图
- 做 UI 时改结局算法；做音效时做动态音乐系统；做引导时接 API
- AI 决定 state_delta / next_node / ending_id
- API 成为游戏必需运行条件
- Label 当 Button 使用
- 调查物直接修改 doubt / control / obedience / anomaly
- 修改 project.godot 的 Autoload（除非用户明确批准）
- 引入未授权素材 / 复杂 Shader / 复杂插件 / 联网发布
- 一次性完成全部 v0.2（必须按 6 阶段推进）
- 完成后宣称"v0.2 已完成"而未通过最终验收标准

## v0.2 阶段提交规则

- 每个阶段只做本阶段目标，不越界
- 每个阶段完成后必须生成报告 `docs/11x_v0_2_X_report.md`
- 报告必须包含：修改文件清单、是否改动核心逻辑、如何验收、静态测试结果、Godot 实机测试结果（或说明未运行）、风险、回滚建议、下一阶段建议
- 小范围修正（错别字/节点路径/bug/函数抽取）可在阶段内顺带做，但必须在报告中说明
