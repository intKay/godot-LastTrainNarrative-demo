# 一分钟垂直切片实现

你现在只实现《叙事校准程序 / 末班车站》的“一分钟垂直切片”，不要完整实现 v0.1。

## 先读文档

开始前必须优先阅读：

- `docs/03_vertical_slice.md`
- `docs/04_system_design.md`
- `docs/05_godot_implementation.md`

## 允许实现的范围

只实现：

- 一个校准问题
- 四个校准 Button
- 记录 `GameState.calibration_hint`
- 进入末班车站
- 车站初始文本
- 公告牌调查
- 一次主线选择
- 主线选择影响 `doubt` / `control` / `obedience` / `anomaly`
- 记录 `last_choice_text`
- 再次调查公告牌显示上一行为
- 主线按钮点击后禁用，不能重复刷状态

## 禁止事项

- 不做完整三轮校准
- 不做完整五轮车站
- 不做结局
- 不接真实 AI API
- 不新增 NPC 系统
- 不做战斗、背包、自由输入、复杂谜题
- 不做复杂美术和复杂音效
- 不把 `Button` 写成 `Label`
- 不让公告牌点击直接增加状态值
- 不一次性重构整个项目
- 不修改 `project.godot` 的 Autoload，除非用户明确确认

## 完成后输出

完成后必须输出：

1. 修改文件列表
2. 每个文件作用
3. Godot 编辑器里需要用户手动设置什么
4. 如何运行
5. 如何验收
6. 如果报错，优先检查哪些节点路径
7. 风险和回滚建议
