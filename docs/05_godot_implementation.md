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
6. 能切换到下一个场景（切片阶段暂不做结局界面）

## 推荐项目目录

```text
project/
  project.godot
  scenes/
    calibration_screen.tscn
    station_scene.tscn
    main_test.tscn
  scripts/
    game_state.gd
    data_loader.gd
    calibration_screen.gd
    station_scene.gd
  data/
    calibration_questions.json
    story_nodes.json
    interactables.json
  docs/
```

> 当前 v0.1 阶段：`ending_screen.tscn`、`endings.json`、`ending_manager.gd` 在阶段 2.6 时创建。音频和美术文件延后到阶段 2.7 之后。

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

v0.1 阶段 2.6 时创建。负责显示三类结局文本。

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

v0.1 暂不需要专门的 MockAIManager 脚本。DataLoader + JSON 直接读取即可。当剧情节点复杂度提升（需要条件分支）时可创建。

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

v0.1 阶段 2.6 时创建。按状态值（doubt/control/obedience）最高维度触发对应结局。

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

### 已完成

| 阶段 | 内容 | 状态 |
|------|------|------|
| 阶段 0 | 最小 UI 玩具：Label + 4 Button + 状态记录 | ✅ |
| 阶段 1 | 一分钟垂直切片：校准→车站→公告牌→选择→残影 | ✅ |
| 阶段 1.1 | 切片打磨：编译警告修复、称呼统一、文本打磨 | ✅ |
| 阶段 2 | 基线固化 + data/ 目录 + AGENTS.md 规则 | ✅ |
| 阶段 2.1 | JSON 数据驱动迁移 | ✅ |

### 后续阶段

| 阶段 | 内容 |
|------|------|
| 阶段 2.2 | 扩展第二轮车站选择（开发中） |
| 阶段 2.3 | 第三轮车站选择 |
| 阶段 2.4 | 四个调查物完整化（时钟/广播灯/出口门交互） |
| 阶段 2.5 | 扩展完整三问校准 |
| 阶段 2.6 | 三个低保真结局 |
| 阶段 2.7 | 低保真 UI / 文本打磨 |
| 阶段 2.8 | 完整试玩与修正 |

## 实现原则

1. 先功能，后美术
2. 先一分钟切片（已完成），再扩展完整 v0.1 流程
3. 先 MockAI，后真实 API
4. 所有复杂功能后置
