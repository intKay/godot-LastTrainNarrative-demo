# v0.2 OpenCode 执行约束

## 1. 文档用途

本文件用于约束 OpenCode / Codex / 其他 AI Agent 在实现《叙事校准程序 / 末班车站》v0.2 时的行为。

必须先读：

```text
docs/101_v0_2_requirement_spec.md
docs/102_v0_2_opencode_execution_constraints.md
```

再开始任何代码或资源修改。

本文件优先级高于临时想法。若用户后续提出新需求，Agent 必须先判断该需求是否违反本文件的范围约束。

## 2. v0.2 当前目标

v0.2 的目标是：

```text
在不扩展主线轮次和结局数量的前提下，
将 v0.1 打磨成可外部试玩的增强版。
```

核心体验必须仍然是：

```text
玩家选择
→ 状态变化
→ 车站反馈
→ 系统记录玩家
→ 系统解释玩家
→ 结局判断
```

v0.2 不追求完整商业 Demo，不追求自由 AI 游戏，不追求复杂美术。

## 3. 最高执行原则

每次修改前必须回答：

```text
这个改动是否让玩家更清楚下一步该做什么？
这个改动是否让选择更明显地反馈到车站空间？
这个改动是否强化"系统正在记录、解释并影响玩家选择"？
这个改动是否会导致范围膨胀？
这个改动是否会破坏 v0.1 已完成闭环？
```

如果答案不明确，先不要改代码。

## 4. 严格禁止

v0.2 禁止：

```text
新增第四轮主线；
新增第四结局；
新增自由输入；
新增 NPC；
新增复杂地图探索；
新增背包 / 道具系统；
新增战斗；
新增复杂谜题；
新增完整动态音乐系统；
让 AI 自由决定剧情；
让 AI 决定结局；
让 AI 修改 state_delta；
让 AI 修改 next_node；
让 AI 新增选项数量；
让 AI 新增场景物件；
让 API 成为游戏必需运行条件；
写入真实 API key / token / credentials；
修改 project.godot 的 Autoload，除非用户明确批准；
大规模重构已跑通的主线状态机；
删除或重命名现有稳定节点，除非同步修复所有引用；
把 Label 当成 Button 使用；
让调查物点击直接修改 doubt/control/obedience/anomaly；
让主线按钮可重复点击刷状态；
使用未授权音频或美术素材；
引入复杂 Shader；
引入复杂插件；
引入联网发布功能。
```

## 5. 必须保留

必须保留 v0.1 已完成行为：

```text
三问校准；
三轮车站主线；
四个调查物；
三个结局；
重新开始；
GameState.reset；
JSON 数据驱动；
无 API 时仍可完整运行；
三类结局可触发；
主线按钮选择后禁用；
调查物点击不刷主状态；
公告屏仍是核心推进 / 记录设备。
```

## 6. 实现顺序约束

必须按阶段推进，不要一次性做完全部 v0.2。

推荐顺序：

```text
v0.2-1：系统待处理项 + 设备按钮视觉化
v0.2-2：车站空间反馈增强
v0.2-3：生成式入场 + 刷新动效
v0.2-4：音效与低频环境音
v0.2-5：Mock AI 动态引导 + 受限选项改写
v0.2-6：完整测试与试玩准备
```

每个阶段完成后必须生成报告。

报告文件命名建议：

```text
docs/111_v0_2_1_guidance_devices_report.md
docs/112_v0_2_2_station_feedback_report.md
docs/113_v0_2_3_generation_refresh_report.md
docs/114_v0_2_4_audio_report.md
docs/115_v0_2_5_mock_ai_guidance_report.md
docs/116_v0_2_6_playtest_ready_report.md
```

## 7. 阶段提交规则

每个阶段只做本阶段目标。

禁止：

```text
在做引导时顺手接 API；
在做 UI 时顺手改结局算法；
在做音效时顺手做动态音乐系统；
在做 AI 引导时顺手新增自由输入；
在做背景时顺手做复杂地图。
```

允许：

```text
小范围修正错别字；
小范围修正节点路径；
小范围修复明确 bug；
小范围抽取可复用函数。
```

但必须在报告里说明。

## 8. JSON 数据约束

v0.2 继续优先数据驱动。

新增内容优先进入：

```text
data/story_nodes.json
data/interactables.json
data/endings.json
data/calibration_questions.json
```

如需要新增 AI mock 数据，可以新增：

```text
data/ai_guidance_mock.json
```

如需要新增设备视觉配置，可以新增：

```text
data/device_states.json
```

但不要为了小需求建立复杂配置系统。

## 9. GameState 约束

可以新增字段，但必须保持含义清楚。

允许新增：

```text
dominant_trait
ai_session_id
ai_guidance_used
ai_rewritten_option_slot
ai_rewritten_option_text
ai_context_cache
audio_enabled
```

不允许改变现有字段含义：

```text
doubt
control
obedience
anomaly
flags
choice_history
last_choice_label
initial_world_hint
current_node_id
```

`anomaly` 不得变成第四结局路线。

`anomaly` 只表示：

```text
叙事噪声 / 系统失真值
```

它可以影响：

```text
文本语气；
刷新强度；
音效失真；
设备异常程度；
AI 触发条件。
```

它不直接决定结局类型。

## 10. UI 约束

v0.2 UI 方向：

```text
冷淡系统 UI
低饱和夜间车站
轻微故障感
低保真几何背景
设备按钮清晰可点
```

必须保证：

```text
玩家一眼知道哪里是主文本；
玩家一眼知道哪里是选项；
玩家一眼知道哪些设备可以点击；
设备按钮 hover / pressed 有反馈；
背景不抢主文本；
背景不伪装成交互物。
```

禁止：

```text
高饱和霓虹；
大量渐变；
复杂花边；
风格不统一 AI 图；
写实角色图；
鬼怪血腥画面；
按钮藏进背景；
过强 glitch 效果。
```

## 11. 设备按钮约束

四个设备横向排列：

```text
[电子公告屏] [时钟] [广播灯] [出口门]
```

形态：

```text
电子公告屏：横向电子公告栏，多行信息；
时钟：方框数字时钟，显示 23:47；
广播灯：圆形灯点 + 标签；
出口门：车站双开门。
```

设备按钮仍然必须是清楚可点的 UI 控件。

不要把它们嵌进背景图。

## 12. 动效约束

动效原则：

```text
少而准；
事件驱动；
可跳过；
不拖慢重玩。
```

允许：

```text
入场背景从上往下生成；
主文本从左往右输出；
公告屏从右往左或局部回刷；
广播灯短暂闪烁；
出口门门缝轻微亮起；
最终判断逐行打印。
```

禁止：

```text
不可跳过长动画；
所有物件同时闪烁；
持续强 glitch；
复杂 Shader；
等待过久的打字机；
影响文本阅读的晃动。
```

入场动画建议 1.2–1.8 秒，并支持点击或按键跳过。

## 13. 音频约束

v0.2 不做旋律型 BGM。

第一版只做：

```text
ambient_station_loop
notice_refresh
choice_commit
device_signal
```

声音原则：

```text
低音量；
短；
克制；
不恐怖；
不干扰阅读；
不使用未授权素材。
```

如找不到合适音频素材，允许先用占位静音接口，不要因音效阻塞其他需求。

## 14. AI 约束总则

v0.2 AI 是"AI 原生雏形"，不是完整 AI 原生系统。

默认必须支持无 API 模式。

API 只能作为实验开关。

必须有 Mock fallback。

v0.2 AI 只能做：

```text
动态引导文本；
系统解释文本；
受限选项显示文本改写。
```

v0.2 AI 不能做：

```text
自由输入；
生成完整主线；
生成结局；
决定 state_delta；
决定 next_node；
新增角色；
新增场景；
新增选项数量；
新增结局；
绕过本地验证。
```

## 15. AI 幻觉控制

AI 只能提到允许对象：

```text
电子公告屏；
时钟；
广播灯；
出口门；
末班车站；
记录；
解释请求；
目的地；
离站许可；
系统建议；
最终判断；
叙事噪声；
校准；
选择历史。
```

禁止提到：

```text
列车员；
乘客；
怪物；
真实城市；
车厢内部；
站外场景；
隐藏房间；
真实逃脱路线；
第四结局；
新 NPC；
不在 UI 中存在的物件。
```

如果 AI 输出越界，必须 fallback。

## 16. AI 上下文污染控制

每次 AI 请求必须使用显式状态包，不依赖模型历史记忆。

每次请求包含：

```text
session_id；
round_id；
phase；
choice_history；
last_choice_label；
clicked_interactables；
doubt/control/obedience/anomaly；
dominant_trait；
allowed_objects；
allowed_actions；
forbidden_content；
output_schema。
```

重新开始游戏时必须：

```text
生成新的 session_id；
清空本地 AI 缓存；
清空 AI 选项改写记录；
调用 GameState.reset。
```

## 17. AI 延时处理

AI 请求可能延时 3–4 秒。

等待期间：

```text
显示"系统正在解释上一行为……"；
显示"公告屏正在回刷……"；
显示"建议项生成中……"；
禁用相关按钮；
播放轻微 notice_refresh / device_signal；
4 秒超时 fallback。
```

fallback 文本：

```text
系统解释超时。
使用本地判断结果。
```

## 18. AI 输出格式约束

如果接 API，必须要求结构化 JSON。

示例：

```json
{
  "safe": true,
  "mode": "guidance",
  "summary_lines": [
    "上一行为已记录：读取电子公告屏。",
    "系统推测：用户正在验证场景是否回应自身选择。",
    "建议项：检查广播源，或查看离站许可。"
  ],
  "suggested_option": {
    "enabled": true,
    "slot": "D",
    "intent": "control",
    "text": "执行系统建议：走向未标记出口"
  },
  "used_trait": "control",
  "should_fallback": false
}
```

本地必须校验：

```text
JSON 是否可解析；
summary_lines 是否 1–3 行；
是否出现 forbidden_content；
slot 是否为 A/B/C/D；
intent 是否为允许值；
text 是否过长；
是否试图改变 state_delta / next_node / ending。
```

校验失败则 fallback。

## 19. OpenCode 测试要求

如果 OpenCode 无法直接运行 Godot，必须做静态测试：

```text
JSON 解析测试；
story_nodes 链路测试；
endings 数据测试；
三条结局路径模拟；
AI fallback 测试；
AI 输出 schema 测试；
禁词 / 越界内容测试；
GameState.reset 字段清零检查。
```

不得声称"Godot F5 已通过"，除非用户或环境实际运行过。

## 20. 每阶段报告要求

每个阶段完成后，必须生成 Markdown 报告，包含：

```text
修改文件清单；
为什么修改；
是否改动核心逻辑；
如何验收；
静态测试结果；
Godot 实机测试结果，如未运行必须说明未运行；
风险；
回滚建议；
下一阶段建议。
```

## 21. 最终禁止总结

不要在完成一个局部阶段后声称：

```text
v0.2 已完成
AI 原生已完成
可以发布商业 Demo
真实 AI 已完全接入
```

除非完成 `docs/101_v0_2_requirement_spec.md` 中所有最终验收标准，并经过用户实机测试。

## 22. 最终目标回顾

v0.2 的三个最重要记忆点是：

```text
车站从上往下被系统生成出来；
玩家选择明显反馈到公告屏、广播灯、时钟、出口门；
系统 / AI 在某一刻改写一个选项，让玩家意识到行动空间也被记录系统影响。
```

如果一个实现不服务这三个记忆点，就不应优先做。
