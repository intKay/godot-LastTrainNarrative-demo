# 《叙事校准程序 / 末班车站》v0.1 Godot 实现方案

## 技术选择

- Godot 4.x
- GDScript
- Control UI 为主
- 不使用 C#
- 不使用 3D
- 不使用真实 AI API
- Linux 本地开发，后续导出 Windows / Linux 桌面版

## 第零阶段：Godot 最小学习与技术验证

目标不是学完整 Godot，而是只学本项目需要的内容。

需要掌握：

1. 场景和节点
2. Control UI
3. Label、Button、Panel、TextureRect
4. 信号 Signals
5. GDScript 基础
6. Dictionary / Array
7. JSON 读取
8. 场景切换
9. 简单 AnimationPlayer

不需要掌握：

1. 物理系统
2. 碰撞系统
3. TileMap
4. 角色控制器
5. 3D
6. 复杂 Shader
7. 网络
8. 多线程

第零阶段验收标准：

1. 能创建 Godot 项目
2. 能做一个 Label + 4 Button 界面
3. 点击按钮后文本变化
4. 能记录一个状态值，例如 doubt += 1
5. 能点击公告牌按钮弹出调查文本
6. 能切换到结局界面

## 推荐项目目录

```text
project/
  project.godot
  scenes/
    main.tscn
    calibration_screen.tscn
    station_scene.tscn
    dialogue_box.tscn
    choice_panel.tscn
    investigation_popup.tscn
    ending_screen.tscn
  scripts/
    game_state.gd
    mock_ai_manager.gd
    calibration_screen.gd
    station_scene.gd
    choice_panel.gd
    interactable_object.gd
    world_state_controller.gd
    ending_manager.gd
  data/
    calibration_questions.json
    story_nodes.json
    interactables.json
    endings.json
  assets/
    art/
    audio/
    fonts/
  docs/
```

## 场景职责

### main.tscn

项目入口。负责加载初始界面。

### calibration_screen.tscn

叙事校准程序界面。显示问题和选项，记录初始选择。

### station_scene.tscn

末班车站主界面。包含背景、公告牌、时钟、广播灯、出口门、文本框和选项区。

### dialogue_box.tscn

负责显示主叙事文本。

### choice_panel.tscn

负责显示 A/B/C/D 选项按钮，并把选择事件传给主场景。

### investigation_popup.tscn

显示调查文本。可作为弹窗，也可以复用主文本框。

### ending_screen.tscn

显示结局文本和选择档案。

## 脚本职责

### game_state.gd

全局状态。建议做成 Autoload。

记录：

- current_stage
- current_node_id
- doubt
- control
- obedience
- anomaly
- flags
- choice_history
- player_name

### mock_ai_manager.gd

读取 JSON 数据并返回当前节点内容。

### calibration_screen.gd

处理开场三问，写入 GameState。

### station_scene.gd

车站主控制器。负责加载节点、更新 UI、响应选项和调查点击。

### choice_panel.gd

生成选项按钮，发出 option_selected 信号。

### interactable_object.gd

每个可点击物件挂载此脚本，点击后请求对应调查文本。

### world_state_controller.gd

更新公告牌、时钟、广播灯、出口门的视觉状态。

### ending_manager.gd

根据 GameState 判断结局。

## UI 节点建议

station_scene.tscn 可以这样组织：

```text
StationScene (Control)
  Background (ColorRect / TextureRect)
  TopBar (HBoxContainer)
    SystemNameLabel
    TimeLabel
  StationArea (Control)
    NoticeBoardButton
    ClockButton
    BroadcastLightButton
    ExitGateButton
  DialogueBox
  ChoicePanel
```

## 开发顺序

### 阶段 0：最小 UI 玩具

1. 创建 Godot 项目
2. 建一个界面
3. 添加 Label 和 4 个 Button
4. 点击按钮后更新文本
5. 记录状态值

### 阶段 1：垂直切片

1. 实现 calibration_screen
2. 实现一个校准问题
3. 切换到 station_scene
4. 实现公告牌点击调查
5. 实现一次主线选择
6. 实现广播灯变化
7. 实现公告牌选择残影

### 阶段 2：完整 v0.1

1. 补齐三问
2. 补齐五轮主线
3. 补齐四个调查物
4. 补齐三个结局
5. 加入选择档案

### 阶段 3：打磨

1. 统一 UI 样式
2. 加入基础音效
3. 加入简单闪烁动画
4. 修复 Bug
5. 试玩审计

## 实现原则

1. 先功能，后美术
2. 先一分钟切片，后完整五轮
3. 先 MockAI，后真实 API
4. 先一个结局，后三个结局
5. 所有复杂功能后置
