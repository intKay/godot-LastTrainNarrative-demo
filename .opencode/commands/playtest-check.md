---
description: 根据本地未提交改动生成手动 F5 测试清单
---

读取 `git diff HEAD --name-only`（未提交的改动）。如果无未提交改动，用 `git diff HEAD~1 --name-only`（最近一次 commit）。

按改动文件类型映射测试步骤：

| 改动文件 | 对应测试内容 |
|---------|------------|
| `data/*.json` | F5 查看对应场景文字是否正确显示、有无错别字/禁词 |
| `scenes/*.tscn` | 对应节点是否可见、布局是否变形、交互是否响应 |
| `scripts/game_state.gd` | `reset()` 后状态清零、新增字段初始化正常 |
| `scripts/calibration_screen.gd` | 校准流程完整、切场景正常 |
| `scripts/station_scene.gd` | 按钮 disabled、调查物只改 flag、节点路径匹配 |
| `scripts/ending_screen.gd` | 三结局可触发、结局文本正确 |
| 音效文件或 Audio 代码 | 对应事件是否发声、音量合理 |

如果 `git diff HEAD` 和 `git diff HEAD~1` 均无结果 → 输出"无可测试改动"。

输出格式：

```
## 手动 F5 测试清单

基于以下改动：
  （改动文件列表）

### 测试项目
- [ ] （步骤描述 / 预期结果 / 失败检查项）
- [ ] ...
```
