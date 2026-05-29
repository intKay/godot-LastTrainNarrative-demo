# 阶段 2.5：优化调查物更新时机与文本刷新反馈 — 完成报告

## 基本信息

- **版本**：阶段 2.5
- **前置条件**：阶段 2.4 四个调查物完整化完成
- **变更性质**：调查物文本更新时机提前 + StoryLabel 刷新闪烁动画
- **测试方式**：Godot 4.6 编辑器内 F5 运行

## 修改文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `scripts/station_scene.gd` | 修改 | 新增 `interactable_stage_id` + `text_tween` 变量；`_load_round_data` 同步 stage_id + 调用 `_flash_story_label`；`_make_choice` 选择后提前推进 stage_id；`_get_interactable_text` 改引用；新增 `_flash_story_label` 方法 |
| `docs/19_phase2_5_feedback_polish_report.md` | 新建 | 本报告 |

**未修改**：`project.godot`、`data/story_nodes.json`、`data/interactables.json`、`scenes/station_scene.tscn`、`main_test.*`、`game_state.gd`、`data_loader.gd`、`calibration_screen.gd`

## 改动详解

### 任务 1：调查物更新时机优化

**方案**：新增 `interactable_stage_id` 与 `current_round_id` 解耦。

```gdscript
var interactable_stage_id: String = "station_round_1"
```

**同步逻辑**（两处）：

| 时机 | `interactable_stage_id` 更新位置 |
|------|---------------------------------|
| 点击"继续"进入下一轮 | `_load_round_data()` 中 `interactable_stage_id = round_id` |
| 选择选项后立即 | `_make_choice()` 中 `if next_round_id != "": interactable_stage_id = next_round_id` |

**引用改造**：`_get_interactable_text()` 从 `texts.get(current_round_id, "")` 改为 `texts.get(interactable_stage_id, "")`。

**生命周期验证**：

| 时间点 | interactable_stage_id | 调查物文本 |
|--------|:---------------------:|-----------|
| 开局 | round_1 | 第一轮文本 |
| 选第一轮后、点继续前 | **round_2** | **第二轮文本** ✅ |
| 点继续后 | round_2 | 第二轮文本（不变） |
| 选第二轮后、点继续前 | **round_3** | **第三轮文本** ✅ |
| 点继续后 | round_3 | 第三轮文本（不变） |
| 选第三轮后（无 next_node） | round_3（不变） | 第三轮文本 ✅ |

### 任务 2：StoryLabel 刷新闪烁

**新增 `_flash_story_label()` 方法**：

```gdscript
func _flash_story_label() -> void:
    if text_tween:
        text_tween.kill()
    story_label.modulate.a = 1.0
    text_tween = create_tween()
    text_tween.tween_property(story_label, "modulate:a", 0.65, 0.08)
    text_tween.tween_property(story_label, "modulate:a", 1.0, 0.12)
```

**触发位置**：`_load_round_data()` 中 `story_label.text = node.visible_text` 之后。

| 场景 | 是否闪烁 |
|------|:--------:|
| 进入新轮次（visible_text 加载） | ✅ |
| 选项反馈文本 | ❌ |
| 公告屏 hint/残影/三次记录/最终判断 | ❌ |
| 调查物文本（时钟/广播灯/出口门） | ❌ |

### 任务 3：可调查提示

当前 UI 布局：

```
[电子公告屏] [■] 广播
[时钟] [广播灯] [出口门]
```

三个调查按钮在 `InteractHBox` 中始终可见，文本直接标明"时钟"/"广播灯"/"出口门"。按钮可见性已足够清晰。**未新增提示文本**。

## 测试结果

### 回归测试

| # | 验收项 | 结果 |
|---|--------|:----:|
| 1 | 校准界面正常 | ✅ |
| 2 | 第一轮：公告屏→选项→继续 | ✅ |
| 3 | 第二轮：公告屏→选项→继续 | ✅ |
| 4 | 第三轮：公告屏→选项→三次记录→最终判断 | ✅ |
| 5 | 主线按钮不可重复点击 | ✅ |
| 6 | 无红色 error / JSON 报错 | ✅ |

### 调查物时机（新增验收）

| # | 操作 | 预期 | 结果 |
|---|------|------|:----:|
| 1 | 第一轮选完后、点继续前，点击时钟 | 显示第二轮文本 | ✅ |
| 2 | 第一轮选完后、点继续前，点击广播灯 | 显示第二轮文本 | ✅ |
| 3 | 第一轮选完后、点继续前，点击出口门 | 显示第二轮文本 | ✅ |
| 4 | 第二轮选完后、点继续前，点击时钟 | 显示第三轮文本 | ✅ |
| 5 | 第二轮选完后、点继续前，点击广播灯 | 显示第三轮文本 | ✅ |
| 6 | 第二轮选完后、点继续前，点击出口门 | 显示第三轮文本 | ✅ |
| 7 | 第三轮选完后，点击调查物 | 仍显示第三轮文本 | ✅ |
| 8 | 公告屏推进逻辑无退化 | 同前 | ✅ |

### 闪烁动画（新增验收）

| # | 检查项 | 结果 |
|---|--------|:----:|
| 1 | 进入车站时 StoryLabel 闪烁一次 | ✅ |
| 2 | 点继续进入第二轮时闪烁一次 | ✅ |
| 3 | 点继续进入第三轮时闪烁一次 | ✅ |
| 4 | 选项反馈文本不触发闪烁 | ✅ |
| 5 | 公告屏文本不触发闪烁 | ✅ |
| 6 | 调查物文本不触发闪烁 | ✅ |
| 7 | 无 Tween 堆积/异常 | ✅ |

## 玩家反馈与待优化（已记录，不做修改）

### 反馈 1：首次入场闪烁太晃眼

进入车站时的全屏 alpha 闪烁（`modulate:a` 从 1.0→0.65→1.0）不够理想。期望改为**从右向左的墨水屏刷新效果**（类似逐列/逐块 wipe 动画），而非全屏闪。

### 反馈 2：每轮文本闪烁需更强更慢

方向正确，但需调整参数：
- **更强**：幅度更大（透明度变化范围更广，或加一些偏移效果）
- **更慢**：持续时间延长

两项 `_flash_story_label()` 的优化留待后续 UI 打磨阶段。如需区分首次入场 vs 轮次切换的不同闪烁效果，需在 `_load_round_data` 中传参或区分调用。

## 已知风险

| 风险 | 说明 | 优先级 |
|------|------|--------|
| `interactable_stage_id` 在第三轮无 next_node 时保持原值 | 行为正确：第三轮选完后调查物文本不变 | 低（已验证） |
| 闪烁动画与后续文本更新时序 | Tween 只改 `modulate.a`，不与 text 内容竞争 | 低 |
| `text_tween.kill()` 确保不叠加 | 每次 `_flash_story_label` 前清理旧实例 | 低 |

## 回滚建议

```bash
git restore scripts/station_scene.gd
```

## 下一阶段建议

| 阶段 | 内容 |
|------|------|
| 2.6 | 扩展校准至完整三问 |
| 2.7 | 结局系统原型 |
| — | 闪烁动画优化（墨水屏效果 + 更慢更强参数）|
