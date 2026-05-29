# 阶段 2.1：JSON 数据驱动迁移 — 完成报告

## 基本信息

- **版本**：阶段 2.1
- **前置条件**：阶段 1.1 基线固化 + 阶段 2 目录准备
- **变更性质**：纯数据迁移，不改玩法、不新增功能
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `data/calibration_questions.json` | 新建 | 1 个校准问题 + 4 个选项 |
| `data/interactables.json` | 新建 | 电子公告屏调查文本 + 残影模板 |
| `data/story_nodes.json` | 新建 | 车站初始文本 + 第一轮主线选项数据 |
| `scripts/data_loader.gd` | 新建 | 14 行，`class_name DataLoader`，静态 `load_json` 方法 |
| `scripts/calibration_screen.gd` | 修改 | 删除硬编码 `options_data`，改为 JSON 读取 |
| `scripts/station_scene.gd` | 修改 | 删除 `hint_texts` + 4 组硬编码选项数据，改为 JSON 读取 |

**未修改**：`project.godot`、`scenes/*.tscn`、`main_test.gd`、`game_state.gd`、`AGENTS.md`

## 从 GDScript 迁移到 JSON 的数据

| 原位置 | 数据 | 迁移目标 |
|--------|------|---------|
| `calibration_screen.gd:9-14` | 校准 4 选项（text/hint/label） | `calibration_questions.json` → `options[]` |
| `station_scene.gd:6-11` | 公告屏 4 种 hint 调查文本 | `interactables.json` → `notice_board.texts_by_hint` |
| `station_scene.gd:23` | 车站初始文本 | `story_nodes.json` → `station_intro.visible_text` |
| `station_scene.gd:54` | 公告屏"已浏览"文本 | `interactables.json` → `notice_board.investigated_text` |
| `station_scene.gd:57` | 残影文本模板 | `interactables.json` → `notice_board.echo_text_template` |
| `station_scene.gd:71-112` | 4 个选项的 text/feedback/state_delta/broadcast_color | `story_nodes.json` → `station_round_1.options[]` |

## 仍保留在 GDScript 的逻辑

| 逻辑 | 原因 |
|------|------|
| 按钮禁用 (`disabled = true`) | 状态控制，非数据 |
| 三段式状态机 (`Phase` enum) | 流程控制 |
| `_show_choices()` / `_hide_choices()` | UI 控制 |
| "校准完成。正在生成场景……" | 过渡文本，非配置数据 |
| 场景切换 `change_scene_to_file` | 流程控制 |
| `_update_broadcast_light` | 颜色设置方法 |


## Godot 中如何验收

打开 Godot 4.6 → Import `last-train-1-min/project.godot` → **F5**，按以下步骤逐一检查。

## 验收步骤

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | F5 启动 | 校准界面显示正常，无红色 error |
| 2 | 点击校准选项（任选） | 按钮禁用，文本变"校准完成。正在生成场景……" |
| 3 | 等待 1.5s | 自动切换到车站 |
| 4 | 车站初始文本 | `你站在一座空车站里。公告屏仍在刷新。广播灯亮着，没有声音。时钟停在 23:47。` |
| 5 | 点击"电子公告屏" | 显示 hint 差异文本（如"灯光参数已载入"），主线选项出现 |
| 6 | 点击主线选项 A/B/C/D | 按钮禁用，广播灯变色，反馈文本正确 |
| 7 | 再次点击"电子公告屏" | 显示"电子公告屏显示：23:47 末班车 目的地：校准中 上一行为：{choice}" |
| 8 | 检查 Output 面板 | 无红色 error，无 `DataLoader:` 报错，无 `UNUSED_PARAMETER` 警告 |

## 与阶段 1.1 体验对比

| 对比项 | 阶段 1.1 | 阶段 2.1 | 一致？ |
|--------|---------|---------|--------|
| 校准界面 | 硬编码 | JSON 读取 | ✅ 完全一致 |
| 校准 4 选项文字 | "A. 一盏整夜没有熄灭的灯" | 同左 | ✅ |
| 剧情切换 | 1.5s 切到 station_scene | 同左 | ✅ |
| 车站初始文本 | "公告屏仍在刷新。广播灯亮着，没有声音。时钟停在 23:47。" | 同左 | ✅ |
| 公告屏 hint 文本 | "灯光参数已载入" 等 4 种 | 同左 | ✅ |
| 主线选项文字 | A/B/C/D 四个 | 同左 | ✅ |
| 主线反馈文本 | "广播灯亮了一下，又熄灭。……" | 同左 | ✅ |
| 广播灯颜色 | 橙/蓝/绿/琥珀 | 同左 | ✅ |
| 按钮禁用 | 选择后全部 disabled | 同左 | ✅ |
| 公告屏残影 | "电子公告屏显示：…上一行为：{choice}" | 同左 | ✅ |
| 状态变化 | doubt/control/obedience/anomaly | 同左 | ✅ |

## 已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| JSON 格式错误 | 拼写错误或多余逗号导致 `JSON.parse_string` 返回 `null`，`DataLoader` 会 `push_error` | 低 |
| 选项索引硬编码 | `station_scene.gd` 中 `_make_choice(0~3)` 与 JSON 数组顺序绑定 | 低（注释已说明） |
| JSON 路径写死 | `"res://data/..."` 路径在脚本中硬编码 | 低 |
| 未添加 `class_name` | `data_loader.gd` 已加 `class_name DataLoader`，全局可访问 | ✅ 已处理 |

## 回滚建议

恢复阶段 1.1 状态：

```bash
git restore scripts/calibration_screen.gd scripts/station_scene.gd
git rm scripts/data_loader.gd data/calibration_questions.json data/interactables.json data/story_nodes.json
git commit -m "回滚阶段 2.1 JSON 迁移"
```

## 测试结果

- **测试日期**：2026-05-29
- **测试方式**：Godot 4.6 编辑器内 F5 运行 + 完整 12 项验收
- **测试结论**：✅ **通过**。阶段 2.1 与阶段 1.1 体验完全一致，无数据退化，无 JSON 读取报错，无红色 error。
- **Output 面板**：无 `DataLoader` 报错信息，无 `UNUSED_PARAMETER` 警告。

## 下一阶段建议

| 阶段 | 内容 |
|------|------|
| 2.2 | 扩展 `story_nodes.json` 至第二轮车站选择 |
| 2.3 | 加入时钟/出口门等新交互物的 JSON 配置 |
| 2.4 | 扩展校准至完整三问 |
| 2.5 | 结局系统原型 |
