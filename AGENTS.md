# 叙事校准程序 / 末班车站

Godot 4.6 + GDScript + Control UI + JSON 数据驱动互动叙事原型。v0.1 完整低保真可试玩原型（3～5 分钟）。

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

## 数据管线

- `data/*.json` → `DataLoader.load_json()` → UI
- 新增内容优先改 JSON，不改核心脚本

## 当前进度

阶段 2.8（含内部验收）已完成。所有 JSON 结构已验证、三条结局路径经 Python 模拟确认正确、代码静态检查无阻塞问题。下一阶段为 Godot F5 实机验收与 v0.1 完成报告（2.9）。

## 自动提交规则

每次修改完成后，必须立即执行：

```bash
git add -A
git commit -m "简短说明"
git push
```

不需要等待用户提示，自行执行。

