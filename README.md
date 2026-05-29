# 《叙事校准程序 / 末班车站》

Godot 4.x + GDScript + Control UI 互动叙事游戏原型。

## 里程碑

- ✅ 阶段 0：Godot 最小 UI 玩具
- ✅ 阶段 1：一分钟垂直切片（已完成基线）
- ✅ 阶段 1.1：切片打磨与结构固化
- ✅ 阶段 2：基线固化与数据驱动准备
- ✅ 阶段 2.1：JSON 数据驱动迁移
- 🔄 阶段 2.2：扩展第二轮车站选择

## 当前目标

**v0.1 完整低保真可试玩原型**

- 预计游玩时长：3～5 分钟
- 技术栈：Godot 4.x + GDScript + Control UI + JSON 数据驱动
- 不接真实 AI API，使用预制 JSON 文本
- 低保真 UI，先功能后美术

## v0.1 包含

1. 三个校准问题
2. 一个末班车站主场景
3. 三轮车站主线选择
4. 四个调查元素（电子公告屏、时钟、广播灯、出口门）
5. 简单状态系统（doubt/control/obedience/anomaly）
6. 三个低保真结局（顺从、怀疑、控制）
7. 基础视觉反馈（按钮禁用、广播灯变色、公告屏残影）

## 一分钟切片（已完成基线）

一分钟切片已完成并通过功能验收。详见 `docs/03_vertical_slice.md`。
所有后续扩展基于此基线，不破坏已有功能。

---

## Windows / Fedora / WSL 多环境开发流程

### 开发规范

1. 每次开始开发前必须先执行 `git pull`。
2. 每次完成一轮修改后必须依次执行：
   ```bash
   git status
   git add .
   git commit -m "简短说明"
   git push
   ```
3. 不要在 Windows、Fedora、WSL 三端同时修改同一个分支。
4. 切换系统前必须先 commit + push。
5. 切换到另一个系统后必须先 pull。
6. Godot 文件名建议统一使用小写和下划线，例如：`main_scene.tscn`、`story_state.gd`、`station_background.png`。
7. 避免大小写混用（例如不要同时出现 `MainScene.tscn` 和 `main_scene.tscn`）。

### 推荐路径

| 环境 | 建议路径 |
|------|---------|
| Windows 原生 | `C:\Users\<用户名>\Projects\<项目名>` |
| WSL | `/home/<用户名>/projects/<项目名>` |
| Fedora | `/home/<用户名>/projects/<项目名>` |

### 重要提醒

- 不建议长期在 `/mnt/c/` 中用 WSL 高频修改 Godot 项目。
- 使用 Windows Godot 编辑器修改了场景或资源后，也必须 commit + push。
- 使用 WSL OpenCode 修改了代码或 docs 后，也必须 commit + push。
