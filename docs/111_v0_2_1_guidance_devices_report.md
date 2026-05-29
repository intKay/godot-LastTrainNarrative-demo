# v0.2-1 引导与设备基础 — 完成报告

## 基本信息

- **版本**：v0.2-1
- **前置条件**：v0.1 完整原型（tag: `v0.1-complete`），v0.2 规划冻结
- **变更性质**：新增 ObjectiveLabel / 主交互高亮 / 设备按钮视觉化 / hover-pressed 反馈
- **测试方式**：静态验证（JSON 解析 + 节点路径一致性 + 代码约束检查）
- **Godot F5 实机测试**：未运行（本环境无 Godot）

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `scenes/station_scene.tscn` | 修改 | 新增 ObjectiveLabel；合并 StationHBox + InteractHBox 为单行设备区；删除 BroadcastLabel；设备按钮 size_flags 分配 |
| `scripts/station_scene.gd` | 修改 | 新增 `_update_objective_label()`、`_update_highlight()`、`_create_device_style()`、`_apply_button_styles()` 四个方法；更新 3 条 `@onready` 路径；6 处调用点插入 |
| `docs/111_v0_2_1_guidance_devices_report.md` | 新建 | 本报告 |

**未修改**：`project.godot`、`game_state.gd`、`calibration_screen.gd`、`ending_screen.gd`、`data/*.json`、`scenes/calibration_screen.tscn`、`scenes/ending_screen.tscn`

## 修改目的

1. **ObjectiveLabel** — 让陌生玩家始终知道下一步该做什么，同时保持冷淡系统 UI 口吻
2. **主交互高亮** — 让玩家视觉焦点始终落在当前应操作的目标上
3. **设备按钮视觉化** — 四个设备从分散两行的纯文字按钮升级为横向排列、带边框/背景色的可识别设备控件
4. **Hover/Pressed 反馈** — 每个设备按钮有 normal/hover/pressed 三种 StyleBoxFlat 状态

## ObjectiveLabel 状态映射

| phase | has_next_round | 文案 |
|-------|---------------|------|
| INTRO | — | 系统待处理项：读取电子公告屏 |
| INVESTIGATED | — | 系统待处理项：选择一项行为 |
| FINISHED | true | 系统待处理项：继续记录 |
| FINISHED | false | 系统待处理项：查看最终判断 |
| END | — | 系统待处理项：记录完成 |

## 主交互高亮映射

| phase | 高亮目标 | 效果 |
|-------|---------|------|
| INTRO | NoticeBoardButton | modulate → (1.0, 1.0, 0.85) 轻微增亮 |
| INVESTIGATED | ChoiceA/B/C/DButton | modulate → (1.0, 1.0, 0.85) 四按钮增亮 |
| END | ChoiceAButton（"查看最终判断"） | modulate → (1.0, 1.0, 0.85) |
| FINISHED | 无高亮 | 全白 |

## 设备按钮视觉分配

| 设备 | TSCN 属性 | StyleBox 配色 |
|------|----------|--------------|
| 电子公告屏 | `size_flags_horizontal = 3` | bg #1C2238 / border #4D6699 |
| 时钟 | `size_flags_horizontal = 1`，文本 "时钟\n23:47" | bg #141926 / border #405980 |
| 广播灯 | `size_flags_horizontal = 1` | bg #141926 / border #664C33 |
| 出口门 | `size_flags_horizontal = 1` | bg #141926 / border #4D594D |

所有按钮均有 `normal` / `hover` / `pressed` 三层 StyleBoxFlat（bg 亮度 ±30%，border 亮度 ±20%）。

## 是否改动核心逻辑

**否**。v0.1 的核心逻辑全部保留：

- 状态机（Phase enum: INTRO → INVESTIGATED → FINISHED → END）未改动
- `_make_choice()`、`_on_notice_board()`、`_show_continue()`、`_on_continue()`、`_show_ending_trigger()` 结构未变
- 主线按钮禁用、调查物不刷状态、公告屏推进路径不变
- GameState 未修改
- JSON 数据未修改

## 验收方式

### 静态验证结果

| 检查项 | 结果 |
|--------|:----:|
| 4 个 JSON 文件可解析 | ✅ 全部通过 |
| story_nodes 链路完整（r1→r2→r3→END） | ✅ 未修改 |
| `@onready` 路径与 TSCN 节点树完全匹配 | ✅ 11/11 条路径通过 |
| 主线按钮 `_disable_choices()` 保留 | ✅ |
| 调查物 handler 不改 `doubt/control/obedience/anomaly` | ✅ |
| 无 Label 冒充 Button | ✅ |
| `_on_continue()` 信号安全（`is_connected` 检查） | ✅ |
| `_show_ending_trigger()` 信号安全 | ✅ |

### ObjectiveLabel 全流程路径验证

| 步骤 | 预期 ObjectiveLabel | 触发点 |
|------|--------------------|--------|
| 初入车站 | 系统待处理项：读取电子公告屏 | `_ready()` → `_update_objective_label()` |
| 点击公告屏 | 系统待处理项：选择一项行为 | `_on_notice_board()` INTRO 分支 |
| 选择 A/B/C/D | 系统待处理项：继续记录 | `_make_choice()` 中 phase = FINISHED + has_next_round |
| 点击"继续"进入下一轮 | 系统待处理项：选择一项行为 | `_on_continue()` 设 phase = INVESTIGATED 后 |
| 第三轮选择后 | 系统待处理项：查看最终判断 | `_make_choice()` 中 phase = FINISHED + 无 next_round |
| 点击公告屏→END | 系统待处理项：记录完成 | `_on_notice_board()` FINISHED 分支 phase = END |
| "查看最终判断"出现 | 系统待处理项：记录完成 | `_show_ending_trigger()` |

### 高亮全流程验证

| 步骤 | 高亮目标 |
|------|---------|
| 初入车站 | NoticeBoardButton |
| 点击公告屏后 | ChoiceA/B/C/D 四按钮 |
| 选择后（FINISHED） | 无高亮 |
| 点击"继续"后 | ChoiceA/B/C/D 四按钮 |
| 第三轮选择后 | 无高亮 |
| 第三轮点击公告屏→END | ChoiceAButton（"查看最终判断"） |
| "查看最终判断"出现 | ChoiceAButton |

## Godot F5 实机测试结果

**未运行**。本环境无 Godot。需用户实机验证以下内容：

1. ObjectiveLabel 显示位置是否合理、文本是否截断
2. 设备按钮横向排列在 1280×720 窗口是否拥挤
3. StyleBoxFlat hover/pressed 颜色过渡是否自然
4. 高亮 modulate 是否明显但不刺眼
5. 时钟按钮双行文本（"时钟\n23:47"）是否显示正确

## 风险

| 风险 | 级别 | 说明 |
|------|:----:|------|
| 按钮文本换行 | 🟡 | 时钟使用 `\n` 双行文本，需实机确认竖直空间是否足够（StationHBox custom_min_height = 44） |
| 窗口缩放布局 | 🟡 | 未测试 1024×768 等小分辨率，`size_flags_horizontal = 3/1/1/1` 在小屏可能让部分按钮过窄 |
| StyleBoxFlat 无字体主题 | 低 | 按钮使用 Godot 默认字体，未设置自定义字体，在部分系统可能不够"冷淡系统感" |
| Phase.END 高亮与查看最终判断 | 低 | Phase.END 时 ChoiceA 同时被高亮和修改文本，两者不冲突 |

## 回滚建议

```bash
git restore scenes/station_scene.tscn scripts/station_scene.gd
```

## 下一阶段建议

v0.2-2：车站空间反馈增强

- 实现 `dominant_trait` 计算（doubt/control/obedience/mixed）
- 每轮一个主反馈物件（第一轮公告屏 / 第二轮广播灯 / 第三轮出口门）
- 时钟 anomaly 辅助反馈
- 结局前行为摘要（系统语言，不显示裸数值）
