# 阶段 1.1 基线状态记录

## 基本信息

- **版本**：阶段 1.1（切片打磨与结构固化）
- **Godot 版本**：4.6
- **渲染**：Forward Plus
- **Autoload**：GameState（`scripts/game_state.gd`）
- **主场景**：`scenes/calibration_screen.tscn`
- **测试日期**：2026-05-29
- **测试结果**：功能通过，无红色报错，无编译警告

## 当前已完成的功能

| 功能 | 状态 | 说明 |
|------|------|------|
| 校准界面 | ✅ | 1 个问题，4 个选项，动态创建 Button |
| 校准选择记录 | ✅ | `initial_world_hint`、`last_choice_label`、`choice_history` |
| 按钮禁用 | ✅ | 校准选择后 4 个按钮 `disabled=true` |
| 延迟场景切换 | ✅ | 1.5s 后 `change_scene_to_file` 到 `station_scene.tscn` |
| 车站初始文本 | ✅ | 展示空车站氛围，含"公告屏、广播灯、时钟停在 23:47" |
| 三段式状态机 | ✅ | INTRO → INVESTIGATED → FINISHED |
| 电子公告屏调查 | ✅ | 4 种 hint 差异文本（light/door/broadcast/ticket） |
| 主线选项显示 | ✅ | 初始隐藏，公告屏调查后 `show()` |
| 主线选择逻辑 | ✅ | 4 个选项，各自影响 `doubt/control/obedience/anomaly` |
| 主线按钮禁用 | ✅ | 选择后 `disabled=true`，不可重复刷状态 |
| 广播灯变色 | ✅ | ColorRect 颜色变化（橙/蓝/绿/琥珀） |
| 选择残影 | ✅ | "电子公告屏显示：23:47 末班车 目的地：校准中 上一行为：{choice}" |
| 公告屏不刷状态值 | ✅ | 仅显示文本，不修改任何核心数值 |
| `UNUSED_PARAMETER` 修复 | ✅ | `calibration_screen.gd:32` 参数 `btn` → `_btn` |
| 称呼统一 | ✅ | 按钮"电子公告屏"，文本"公告屏"，反馈"电子公告屏显示" |

## 当前运行入口

- **project.godot** — `run/main_scene="res://scenes/calibration_screen.tscn"`
- **Autoload** — `GameState="*res://scripts/game_state.gd"`
- 启动方式：Godot 4.6 → Import → F5

## 当前核心流程

```
F5 启动
  → calibration_screen.tscn (校准界面)
    → 点击 A/B/C/D
      → 按钮禁用，隐藏标题/说明/问题
      → 显示 "校准完成。正在生成场景……场景确认：末班车站。"
      → 1.5s 后
        → station_scene.tscn (车站场景)
          → 初始文本：空车站氛围
          → 点击"电子公告屏"
            → (INTRO) 显示 hint 差异文本 + 主线选项出现
            → (INVESTIGATED) 显示"公告屏依旧亮着"
            → 点击主线选项 A/B/C/D
              → 按钮禁用 + 状态更新 + 广播灯变色
              → phase = FINISHED
            → 再次点击"电子公告屏"
              → (FINISHED) 显示"电子公告屏显示：23:47  末班车\n目的地：校准中\n上一行为：{choice}"
```

## 当前验收步骤

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | F5 启动 | 校准界面：标题 + 说明 + 问题 + 4 个 Button |
| 2 | 点击任一校准选项 | 按钮禁用，显示"校准完成。正在生成场景……" |
| 3 | 等待 1.5s | 自动切换到车站场景 |
| 4 | 阅读车站初始文本 | `你站在一座空车站里。公告屏仍在刷新。广播灯亮着，没有声音。时钟停在 23:47。` |
| 5 | 点击"电子公告屏" | 显示 hint 差异文本，主线选项出现 |
| 6 | 点击主线选项 A/B/C/D | 按钮禁用，广播灯变色 |
| 7 | 再次点击"电子公告屏" | 显示"上一行为：{主线选择}" |

## 当前不应破坏的行为（保护清单）

| # | 行为 | 保护级别 |
|---|------|---------|
| 1 | F5 启动进入校准界面 | 🔴 不可破坏 |
| 2 | 校准界面 4 个 Button（非 Label） | 🔴 不可破坏 |
| 3 | 校准选择后按钮禁用 | 🔴 不可破坏 |
| 4 | 1.5s 后自动切换到 `station_scene.tscn` | 🔴 不可破坏 |
| 5 | 车站初始文本含"公告屏仍在刷新/广播灯亮着/时钟停在 23:47" | 🔴 不可破坏 |
| 6 | 首次点击公告屏显示 hint 差异文本 | 🔴 不可破坏 |
| 7 | 主线选项初始隐藏，公告屏调查后可见 | 🔴 不可破坏 |
| 8 | 主线选择后按钮禁用 | 🔴 不可破坏 |
| 9 | 广播灯 ColorRect 变色 | 🔴 不可破坏 |
| 10 | 选择后公告屏显示"上一行为" | 🔴 不可破坏 |
| 11 | `GameState` 跨场景保留 | 🔴 不可破坏 |
| 12 | `main_test.tscn` 独立可运行 | 🟡 保留即可 |
| 13 | 无 `UNUSED_PARAMETER` 编译警告 | 🟢 保持即可 |
| 14 | 称呼统一：按钮/文本/反馈不混用 | 🟢 保持即可 |

## 当前已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| 节点路径硬编码 | `calibration_screen.gd` 和 `station_scene.gd` 中 `@onready` 路径依赖 TSCN 节点名 | 低 |
| 无 JSON 数据管线 | 所有文本和选项数据硬编码在脚本中 | 中（阶段 2.1 目标）|
| 只支持 1 轮校准 | `options_data` 在脚本中写死，扩展需加数组项 | 中（阶段 2.4 目标）|
| 只支持 1 轮主线 | `station_scene.gd` 状态机只支持 1 轮选择 | 中（阶段 2.3 目标）|
| Godot 编辑器 uid 文件 | `scripts/*.gd.uid` 由 Godot 自动生成，不影响功能 | 低 |

## 后续扩展原则

1. **先 JSON 后逻辑** — 新增剧情/选项时优先扩展 JSON 而非重写脚本
2. **不破坏 1.1 基线** — 任何改动必须通过"14 条保护清单"验证
3. **小步迭代** — 每次只改 1 个维度（数据/UI/状态/文本），不改完才验证
4. **名称统一** — 程序 ID 用英文（如 `station_round_2`），显示文本用中文
5. **公告屏不刷状态** — 后续新增交互物同样遵守此规则
6. **主线按钮禁用** — 任何新增主线选择同样遵守此规则

## 当前文件结构

```
project/
├── project.godot
├── data/                          ← 新建，空目录
├── scenes/
│   ├── calibration_screen.tscn
│   ├── station_scene.tscn
│   └── main_test.tscn            ← 阶段 0 技术验证，保留
├── scripts/
│   ├── game_state.gd             ← Autoload
│   ├── calibration_screen.gd
│   ├── station_scene.gd
│   └── main_test.gd
├── docs/                         ← 14 份文档
├── .opencode/
│   ├── commands/
│   │   ├── playtest-check.md
│   │   ├── review-scope.md
│   │   └── vertical-slice.md
│   └── skills/
│       └── godot-narrative-slice/SKILL.md
└── AGENTS.md
```
