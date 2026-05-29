---
description: 审计当前修改是否符合 v0.2 范围约束
---

先读取 docs/102 §4（严格禁止）、§5（必须保留）。

然后对当前所有未提交的修改（`git diff --name-only` 和 `git diff`）逐项检查：

## 范围越界检查
1. 是否新增第四轮主线 / 第四结局？
2. 是否新增自由输入 / NPC / 战斗 / 背包 / 复杂地图 / 复杂谜题？
3. 是否让 AI 决定 state_delta / next_node / ending_id / 选项数量？
4. 是否让 API 成为默认运行依赖？
5. 是否写入真实 API key / token / credentials？
6. 是否修改了 project.godot 的 Autoload（且未经用户明确批准）？
7. 是否引入未授权音频/美术素材、复杂 Shader、复杂插件或联网发布？
8. 是否一次性做了多个 v0.2 阶段的内容？

## 代码质量检查
9. 主线按钮选择后是否仍然 disabled？
10. 调查物 handler 是否直接修改 doubt/control/obedience/anomaly？
11. 是否用 Label 代替 Button 做可点击交互？
12. 是否大规模重构已跑通的主线状态机？

## 输出格式

```
审查结论：通过 / 需要收窄 / 不建议合并
范围膨胀点：（逐项列出）
必须修复的问题：（逐项列出）
可以延后的内容：（逐项列出）
```
