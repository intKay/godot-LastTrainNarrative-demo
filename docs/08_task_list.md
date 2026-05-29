# 《叙事校准程序 / 末班车站》v0.1 开发任务清单

## 已完成

### 阶段 0：Godot 最小练习 ✅

1. 创建 Godot 4.x 项目
2. 创建 Control UI + Label + 4 个 Button
3. 点击 Button 后更新 Label 文本
4. 记录状态值（doubt/control/obedience/anomaly）
5. 公告牌按钮显示调查文本

### 阶段 1：一分钟垂直切片 ✅

1. 创建 `calibration_screen.tscn`
2. 实现一个校准问题 + 4 个选项
3. 创建 `station_scene.tscn`
4. 从校准界面切换到车站界面
5. 实现公告牌点击调查
6. 实现第一轮主线选项
7. 实现选项点击后的状态变化
8. 实现广播灯视觉变化
9. 实现公告牌显示选择残影

### 阶段 1.1：切片打磨与结构固化 ✅

1. 修复 `UNUSED_PARAMETER` 编译警告
2. 统一称呼（公告牌→公告屏/电子公告屏）
3. 打磨车站初始文本
4. 打磨调查文本

### 阶段 2：基线固化与数据驱动准备 ✅

1. 创建基线文档 `docs/14_phase1_1_baseline.md`
2. 创建 `data/` 目录占位
3. AGENTS.md 新增报告写入规则

### 阶段 2.1：JSON 数据驱动迁移 ✅

1. 创建 `data/calibration_questions.json`
2. 创建 `data/interactables.json`
3. 创建 `data/story_nodes.json`
4. 创建 `scripts/data_loader.gd`
5. `calibration_screen.gd` 改为 JSON 读取
6. `station_scene.gd` 改为 JSON 读取

### 阶段 2.2：扩展第二轮车站选择 ✅

1. `story_nodes.json` 新增 `station_round_2` 节点
2. `station_scene.gd` 状态机升级为 4 阶段 + 继续按钮
3. Bug 修复：第二轮 B/C/D 按钮循环恢复

### 阶段 2.3：第三轮车站选择 ✅

1. `story_nodes.json` 新增 `station_round_3` 节点 + round_2 转向 round_3
2. `station_scene.gd` `_on_notice_board` 适配最后一轮结束语/残影
3. `interactables.json` 新增 `three_rounds_end_text` / `echo_text_final`

### 阶段 2.4：四个调查物完整化 ✅

1. `scenes/station_scene.tscn` 新增 InteractHBox + 时钟/广播灯/出口门 三个 Button
2. `data/interactables.json` 追加 clock / broadcast_light / exit_gate 三个对象
3. `scripts/station_scene.gd` 新增 `_get_interactable_text` + 3 个调查 handler

### 阶段 2.5：优化调查物时机与文本刷新反馈 ✅

1. `scripts/station_scene.gd` 新增 `interactable_stage_id` 解耦调查物查表；`_make_choice` 选择后提前推进
2. `scripts/station_scene.gd` 新增 `_flash_story_label` + `text_tween`，每轮 visible_text 加载时闪烁

## 待完成

### 阶段 2.6：扩展完整三问校准 📋

1. `calibration_questions.json` 扩展为 3 问
2. `calibration_screen.gd` 支持多问循环
3. 第二问和第三问影响车站初始状态

### 阶段 2.7：三个低保真结局 📋

1. 创建 `endings.json`
2. 创建结局判断逻辑（按状态值最高维度触发）
3. 顺从结局 / 怀疑结局 / 控制结局文本

### 阶段 2.8：低保真 UI / 文本打磨 📋

1. 统一视觉风格
2. 按钮悬停反馈
3. 异常抖动效果
4. 文本一致性和张力检查

### 阶段 2.9：完整试玩与修正 📋

1. 按照 v0.1 完整原型试玩检查表测试
2. 修复发现的 Bug
3. 确认 3～5 分钟流程闭环
4. 输出 v0.1 完成报告

## 优先级原则

优先做：
1. 选择反馈
2. 状态系统
3. 车站元素变化
4. 数据驱动内容

暂时不做：
1. 真实 AI
2. 复杂美术
3. 自由输入
4. 角色移动
5. 多 NPC
6. 背包支线
7. 动态音乐
8. 联网功能
9. Web / 手机端适配
