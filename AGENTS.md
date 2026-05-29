# 叙事校准程序 / 末班车站

本项目是 Godot 4.x + GDScript + Control UI 互动叙事游戏原型。当前阶段基于已完成的一分钟垂直切片，扩展 v0.1 完整低保真原型。

## 项目里程碑

- ✅ 阶段 0：Godot 最小 UI 玩具
- ✅ 阶段 1：一分钟垂直切片（已完成基线）
- ✅ 阶段 1.1：切片打磨与结构固化
- ✅ 阶段 2：基线固化与数据驱动准备
- ✅ 阶段 2.1：JSON 数据驱动迁移
- 🔄 阶段 2.2：扩展第二轮车站选择

## 当前目标

一分钟垂直切片已作为基线完成。当前目标是基于该基线扩展 **v0.1 完整低保真可试玩原型**：

- 三个校准问题
- 三轮车站主线选择
- 四个调查元素（电子公告屏、时钟、广播灯、出口门）
- 三个低保真结局（顺从、怀疑、控制）
- JSON 数据驱动 + Godot 4.x + GDScript + Control UI

## 文档优先级

所有实现必须优先参考 `docs/` 下的 Markdown 文档。

开发前优先阅读：

1. `docs/00_project_overview.md`
2. `docs/01_game_design.md`
3. `docs/02_narrative_design.md`
4. `docs/03_vertical_slice.md`
5. `docs/04_system_design.md`
6. `docs/05_godot_implementation.md`
7. `docs/06_ui_art_audio_guide.md`
8. `docs/07_content_data_spec.md`
9. `docs/08_task_list.md`
10. `docs/09_risk_review.md`
11. `docs/10_playtest_checklist.md`

当前文档入口统一为 `docs/`。

## 范围审计

新增功能必须先做范围审计，确认它是否服务于：

- 玩家是否理解自己做出选择
- 状态是否被记录
- 车站是否反馈玩家选择
- 系统是否表现出正在观察玩家
- 结局是否与玩家选择模式一致

如果功能不服务于 v0.1 完整原型，应延后。

## 禁止事项

当前阶段禁止：

- 真实 AI API
- 自由文本输入
- 多 NPC 系统
- 战斗
- 背包
- 复杂 2D 移动
- 复杂谜题
- 复杂美术
- 复杂音频
- 超过 v0.1 范围（不做 5 轮、不做商业版、不做联网功能）
- 一次性实现完整 v0.1（应分阶段逐步扩展）
- 未经确认修改 `project.godot` 的 Autoload
- 写入 API key、token 或 provider credentials

## Godot 实现规则

- 使用 Godot 4.x 和 GDScript。
- UI 以 Control 节点为主。
- Godot 节点命名必须稳定、可读，避免随意重命名。
- 需要点击的选项必须使用 `Button`，不要误用 `Label`。
- 主线按钮点击后必须全部禁用，避免重复刷状态。
- 公告牌调查只显示文本或设置 flag，不直接刷 `doubt`、`control`、`obedience`、`anomaly` 等状态值。
- 状态变化应只发生在明确的主线选择中。
- 节点路径必须和 `.tscn` 实际结构一致，避免硬编码不存在的节点。

## 叙事文本规则

文本应短、冷、准、有信息量，体现系统化的记录感。每句话至少承担一个作用：反馈选择、提供信息、推进认知、暗示记录或引导下一步。

避免长篇散文、纯氛围描写、过早解释"你被测试了"、恐吓式惊吓和无反馈选择。

## 每次修改后的报告格式

每次修改后必须说明：

1. 修改了哪些文件
2. 为什么改
3. 如何在 Godot 中验收
4. 风险和回滚建议

如果涉及 Godot 场景，还需要说明：

- 在 Godot 编辑器里需要手动设置什么
- 运行哪个场景
- 点击哪些按钮
- 如果报错，优先检查哪些节点路径

修改完成并经测试验证后，必须将修改说明和验收结果写入 `docs/` 下的 Markdown 文件（如 `docs/12_playtest_report_phase1.md`），以便后续查阅和回溯。不要只在对话中记录。
