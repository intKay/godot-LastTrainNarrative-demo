# 《叙事校准程序 / 末班车站》开发任务清单

## v0.1 已完成

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

### 阶段 2.6：扩展完整三问校准 ✅

1. `data/calibration_questions.json` 扩展为 3 问，每问 4 选项含 state_delta
2. `scripts/calibration_screen.gd` 重写为多问循环（逐问显示→选择→delta→下一问→完成切场景）
3. `state_delta`/`set_flags` 实际生效，校准首次对状态系统产生影响

### 阶段 2.7：三个低保真结局 ✅

1. `data/endings.json` 含顺从/怀疑/控制三结局文本
2. `scripts/ending_screen.gd` 按状态值最高维度判断结局
3. `station_scene.gd` 第三轮后触发"查看最终判断"→ ending_screen，`game_state.gd` 新增 `reset()`

### 阶段 2.8：文本精修 + 低保真 UI 统一 ✅

1. `data/endings.json` 三结局正文加意象描写（灯光熄灭/问题列表/风倒错）
2. `data/story_nodes.json` round_3 visible_text 第三行措辞修正
3. `scenes/ending_screen.tscn` BodyLabel 字号 16→18，居中

### 阶段 2.9：完整试玩与修正

1. 按照 v0.1 完整原型试玩检查表测试
2. 修复发现的 Bug
3. 确认 3～5 分钟流程闭环
4. 输出 v0.1 完成报告

## v0.2 开发任务清单

### v0.2-1：引导与设备基础 📋

1. 新增系统待处理项 ObjectiveLabel
2. 主交互高亮（公告屏 / 选项区 / 最终判断按钮）
3. 设备按钮横向视觉化（电子公告屏 / 时钟 / 广播灯 / 出口门）
4. 基本 hover / pressed 状态
5. 更新 `data/device_states.json` 或配置
6. 输出 `docs/111_v0_2_1_guidance_devices_report.md`

### v0.2-2：车站空间反馈增强 📋

1. 实现 `dominant_trait` 计算（doubt/control/obedience/mixed）
2. 每轮一个主反馈物件（第一轮公告屏 / 第二轮广播灯 / 第三轮出口门）
3. 时钟 anomaly 辅助反馈（23:47 异常表现）
4. 结局前行为摘要（系统语言，不显示数值）
5. `anomaly` 影响文本语气 / 刷新强度，不决定结局
6. 输出 `docs/112_v0_2_2_station_feedback_report.md`

### v0.2-3：生成式入场与刷新动效 📋

1. 低保真几何车站背景（线条 / 矩形 / 圆圈 / 低饱和色）
2. 入场动画：背景从上往下逐行显现 → 设备逐个显现 → 主文本刷新 → ObjectiveLabel
3. 动画可跳过（点击或空格）
4. 主文本从左往右输出 / 公告屏从右往左回刷
5. 背景与按钮分离，不干扰交互
6. 输出 `docs/113_v0_2_3_generation_refresh_report.md`

### v0.2-4：音效与环境音 📋

1. `ambient_station_loop` — 低频环境底噪
2. `notice_refresh` — 公告屏刷新 / 跳字声
3. `choice_commit` — 主线选择确认声
4. `device_signal` — 通用设备反馈声（复用给广播灯/出口门/时钟）
5. 输出 `docs/114_v0_2_4_audio_report.md`

### v0.2-5：Mock AI 动态引导与选项改写 📋

1. Mock AI 动态引导（根据状态生成系统解释文本）
2. 受限选项改写（anomaly >= 2 时改写 D 选项文本）
3. AI 等待 UI（"系统正在解释……" + 按钮禁用）
4. 4 秒超时 fallback
5. 可选 API 实验开关（默认 Mock）
6. 输出 `docs/115_v0_2_5_mock_ai_guidance_report.md`

### v0.2-6：完整测试与试玩准备 📋

1. 顺从路径测试
2. 怀疑路径测试
3. 控制路径测试
4. AI 介入路径测试
5. 重开清零测试
6. 音效开关测试
7. 无 API fallback 测试
8. 导出试玩包准备
9. 输出 `docs/116_v0_2_6_playtest_ready_report.md`

## v0.1 优先级原则（延续适用）

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
