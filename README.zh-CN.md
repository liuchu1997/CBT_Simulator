**[English](./README.md)** | **中文**

# CBT 心理治疗模拟器

一款基于**认知行为疗法（CBT）**的宝可梦风格 JRPG 教育模拟游戏。玩家扮演心理咨询师，通过与虚拟患者对话、选择治疗策略，帮助患者识别认知扭曲并实现心理成长。

**引擎：** Godot 4.4 · **语言：** GDScript · **分辨率：** 640×480 像素风

---

## 目录

- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [架构设计](#架构设计)
- [游戏流程](#游戏流程)
- [按键操作](#按键操作)
- [扩展指南](#扩展指南)
- [测试](#测试)
- [已知限制](#已知限制)

---

## 功能特性

| 功能 | 说明 |
|---|---|
| **3位患者** | 林小雨（抑郁）、张浩（焦虑）、王美（个人化），各5次治疗深度对话 |
| **7态情绪系统** | 防御→试探→敞开心扉→情绪泛滥→抗拒→反思→领悟 |
| **属性克制表** | 7种CBT技能 × 7种情绪状态，类似宝可梦属性克制（×3.0 拔群 / ×0.1 无效） |
| **隐藏信念发现** | 每位患者3个隐藏核心信念（Schema），治疗中可逐步揭示 |
| **5维评分** | 共情、倾听、苏格拉底提问、认知重构、关系建立 |
| **3线技能树** | 认知重构/行为激活/共情倾听，每线4级，解锁高级对话选项 |
| **章节驱动** | 4章 + 终章，逐步解锁患者，需满足技能等级和评分门槛 |
| **情绪NPC教学** | 4个情绪精灵（怒/忧/恐/悦）教玩家识别认知扭曲 |
| **信任/羁绊** | 信任度影响患者对话内容和结局，有衰减机制 |
| **多结局对话** | 结局根据评分等级（S/A/B/C/D）、信任度、BattleEngine状态动态生成 |
| **存档系统** | 自动保存到 `user://save_data.json`，支持手动保存和重置 |

---

## 快速开始

### 环境要求

- **Godot 4.4.1+**（[下载页](https://godotengine.org/download) 或国内镜像）
- 操作系统：Windows / macOS / Linux
- 无需额外依赖

### 安装步骤

```bash
# 1. 克隆项目
git clone <仓库地址>
cd CBT_Simulator

# 2. 用 Godot 编辑器打开项目
#    方式 A：命令行启动
godot --path .

#    方式 B：Godot 编辑器 → 扫描 → 导入项目 → 双击打开

# 3. 首次打开会自动生成 .godot/ 缓存和 .import 文件（约30秒）

# 4. 运行游戏
#    编辑器内按 F5，或命令行：
godot --path .
```

### 运行测试

```bash
# 清除存档（避免测试数据干扰）
rm -f ~/.local/share/godot/app_userdata/CBT\ Therapy\ Simulator/save_data.json

# 运行18项自动化测试
godot --headless --path . --script tests/test_runner.gd
```

预期输出：`Total: 18 | Passed: 18 | Failed: 0 >>> ALL TESTS PASSED! <<<`

---

## 项目结构

```
CBT_Simulator/
├── project.godot                    # 项目配置（ autoload / 输入映射 / 物理层 ）
├── theme.tres                       # 默认 UI 主题
├── icon.svg                         # 项目图标
│
├── assets/
│   └── sprites/
│       ├── characters/              # 角色像素精灵（每角色8方向×2状态）
│       │   ├── therapist/           # 玩家治疗师
│       │   ├── lin_xiaoyu/          # 林小雨（抑郁患者）
│       │   ├── zhang_hao/           # 张浩（焦虑患者）
│       │   ├── wang_mei/            # 王美（人格障碍患者）
│       │   └── npc_receptionist/    # 前台接待员
│       ├── tilesets/
│       │   └── indoor.png           # 室内地图图块集
│       └── ui/                      # UI 素材（待填充）
│
├── audio/
│   ├── bgm/                         # 背景音乐（待填充）
│   └── sfx/                         # 音效（待填充）
│
├── fonts/
│   └── NotoSansSC-Regular.otf       # 中文字体
│
├── scenes/
│   ├── main_menu.tscn               # 主菜单场景（入口）
│   ├── game_world.tscn              # 游戏世界（地图+角色+HUD）
│   ├── characters/                  # 角色 PackedScene
│   │   ├── player.tscn              #   玩家（CharacterBody2D）
│   │   ├── patient_linxy.tscn       #   林小雨
│   │   ├── patient_zhangh.tscn      #   张浩
│   │   ├── patient_wangmei.tscn     #   王美
│   │   ├── npc_receptionist.tscn    #   前台
│   │   └── emotion_*.tscn           #   4个情绪NPC
│   ├── rooms/                       # 房间场景
│   │   ├── room_depression.tscn     #   抑郁系诊室（蓝色）
│   │   ├── room_anxiety.tscn        #   焦虑系诊室（橙色）
│   │   ├── room_personality.tscn    #   人格系诊室（紫色）
│   │   └── room_crisis.tscn         #   危机干预室（红色）
│   └── ui/                          # UI 组件
│       ├── dialogue_box.tscn        #   对话框
│       ├── battle_hud.tscn          #   战斗面板（alliance/属性/状态）
│       ├── score_report.tscn        #   评分报告
│       ├── skill_tree.tscn          #   技能树
│       ├── journal.tscn             #   治疗日记
│       ├── pause_menu.tscn          #   暂停菜单
│       ├── chapter_complete.tscn    #   章节完成
│       ├── patient_profile_ui.tscn  #   患者档案
│       ├── achievement_popup.tscn   #   成就弹窗
│       ├── tutorial_card.tscn       #   教学卡片
│       └── tutorial.tscn            #   教程
│
├── scripts/
│   ├── main_menu.gd                 # 主菜单逻辑
│   ├── map_builder.gd               # 地图构建（TileMap绘制+角色放置）
│   ├── player_controller.gd         # 玩家移动+交互
│   ├── patient.gd                   # 患者对话树（734行，核心脚本）
│   ├── npc_base.gd                  # NPC基类
│   ├── emotion_npc.gd               # 情绪教学NPC
│   ├── autoload/                    # 全局单例（8个）
│   │   ├── game_manager.gd          #   游戏状态/存档/章节/解锁
│   │   ├── battle_engine.gd         #   情绪状态机+属性克制+Schema发现
│   │   ├── scoring_system.gd        #   5维评分引擎
│   │   ├── dialogue_manager.gd      #   对话队列+选择系统
│   │   ├── skill_tree.gd            #   3线技能树+评分倍率
│   │   ├── room_manager.gd          #   房间切换+章节映射
│   │   ├── cbt_tutorial.gd          #   教学触发系统
│   │   └── font_loader.gd           #   中文字体自动加载
│   ├── rooms/
│   │   └── room_base.gd             # 房间基类
│   └── ui/                          # UI 脚本（对应 scenes/ui/）
│       ├── dialogue_box.gd
│       ├── battle_hud.gd
│       ├── score_report.gd
│       ├── skill_tree_ui.gd
│       ├── journal_ui.gd
│       ├── pause_menu.gd
│       ├── chapter_complete.gd
│       ├── patient_profile_ui.gd
│       ├── achievement_popup.gd
│       ├── tutorial_card.gd
│       └── tutorial.gd
│
└── tests/
    ├── test_runner.gd               # 测试启动器（SceneTree模式）
    ├── test_all.gd                  # 18项测试用例
    └── test_scene.tscn              # 测试场景
```

---

## 架构设计

### Autoload 全局单例（按加载顺序）

| 单例 | 脚本 | 行数 | 职责 |
|---|---|---|---|
| `GameManager` | `autoload/game_manager.gd` | 455 | 游戏状态中枢：会话管理、患者解锁、章节推进、存档/读档、信任/羁绊、成就 |
| `ScoringSystem` | `autoload/scoring_system.gd` | 88 | 5维评分：共情/倾听/苏格拉底/认知重构/关系建立，生成评级(S/A/B/C/D) |
| `DialogueManager` | `autoload/dialogue_manager.gd` | 114 | 对话队列：文本显示、选择菜单、回调、冷却 |
| `SkillTree` | `autoload/skill_tree.gd` | 90 | 3线技能（认知/行为/共情），4级进阶，评分倍率 |
| `CbtTutorial` | `autoload/cbt_tutorial.gd` | 67 | 首次触发教学卡片 |
| `FontLoader` | `autoload/font_loader.gd` | 18 | 递归应用 NotoSansSC 中文字体 |
| `BattleEngine` | `autoload/battle_engine.gd` | 320 | 7态情绪FSM、技能×状态属性克制表、Schema发现 |
| `RoomManager` | `autoload/room_manager.gd` | 84 | 5房间管理、患者→房间映射、背景色切换 |

### 核心信号流

```
玩家按空格交互
  → patient.gd.on_interact()
    → DialogueManager.start_dialogue()          # 显示对话
    → 玩家选择 → BattleEngine.apply_skill()     # 计算属性克制
      → alliance_changed / state_changed / battle_effect / schema_discovered
    → ScoringSystem.record_choice()             # 记录评分
  → patient.gd.end_session()
    → GameManager.end_session()                  # 更新进度
    → GameManager.check_chapter_completion()     # 检查章节完成
      → chapter_completed / patient_unlocked
    → RoomManager.return_to_lobby()              # 回到大厅
```

### 物理碰撞层

| 层 | 名称 | 用途 |
|---|---|---|
| 1 | player | 玩家角色 |
| 2 | npc | NPC/患者 |
| 3 | walls | 墙壁碰撞 |
| 4 | objects | 家具/物体碰撞 |

### 情绪状态机（BattleEngine）

```
                 好技能                    好技能
  GUARDED ──────────→ TESTING ──────────→ OPENING_UP
     │                                      │  │
     │坏技能                      好技能    │  │情绪过激
     ↓                         ┌───────────┘  ↓
  RESISTANT ←──────────────  REFLECTIVE ←── EMOTIONALLY_FLOODED
                               │
                               │好技能
                               ↓
                            INSIGHT（领悟）
```

### 属性克制表（技能 × 情绪状态，部分示例）

| 技能 | GUARDED | TESTING | REFLECTIVE | RESISTANT |
|---|---|---|---|---|
| reflection（反映） | **×3.0 拔群** | ×2.0 | ×1.0 | ×2.0 |
| cognitive_restructuring（认知重构） | **×0.1 无效** | ×1.5 | ×2.5 | ×0.5 |
| validation（确认） | ×2.0 | ×1.5 | ×1.0 | ×2.5 |
| behavioral_activation（行为激活） | ×0.5 | ×1.0 | ×2.0 | ×0.5 |

> 设计理念：患者防御时用共情/反映类技能"破防"，反思时用认知重构类技能才有效。

---

## 游戏流程

```
主菜单 → 点击"开始游戏"
  → game_world.tscn（40×30 格子地图）
    → WASD 移动角色
    → 靠近 NPC → 空格键对话
      → 情绪NPC：CBT知识问答（正确+2/错误-1）
      → 患者：多轮治疗对话（含选择分支）
        → 每次选择触发 BattleEngine 属性计算
        → 评分报告（5维+评级+反馈）
    → 完成3次治疗 → 章节评级检查
      → 通过 → 解锁下一位患者 + 新章节
      → 未通过 → 可重试
  → ESC 暂停（保存/重置/返回主菜单）
```

### 章节进度

| 章节 | 患者 | 治疗次数 | 最低评级 | 技能要求 |
|---|---|---|---|---|
| 第一章：初入诊室 | 林小雨（抑郁） | 3 | D | 无 |
| 第二章：焦虑的面具 | 张浩（焦虑） | 3 | D | 认知Lv.1 + 共情Lv.1 |
| 第三章：自我归因 | 王美（个人化） | 3 | C | 认知Lv.2 + 共情Lv.2 |
| 终章：治疗师的成长 | 综合考核 | 1 | B | 认知Lv.3 + 行为Lv.2 + 共情Lv.3 |

### 评级阈值

| 总分 | 评级 |
|---|---|
| ≥12 | S |
| ≥10 | A |
| ≥7 | B |
| ≥4 | C |
| <4 | D |

---

## 按键操作

| 按键 | 动作 | 说明 |
|---|---|---|
| W/A/S/D 或 方向键 | 移动 | 格子移动，16px 步进 |
| 空格 或 J | 交互 | 与面对的 NPC 对话 |
| K | 技能树 | 打开/关闭技能升级面板 |
| J | 日记 | 查看治疗日记 |
| I | 档案 | 查看患者档案 |
| ESC | 暂停 | 暂停菜单（保存/重置/退出） |

---

## 扩展指南

### 添加新患者

1. **创建精灵**：在 `assets/sprites/characters/` 下新建目录，放入 8 张 16×16 PNG：
   - `idle_down.png`, `idle_up.png`, `idle_left.png`, `idle_right.png`
   - `walk_down.png`, `walk_up.png`, `walk_left.png`, `walk_right.png`
   - 打开 Godot 编辑器让其自动生成 `.import` 文件

2. **创建场景**：复制 `scenes/characters/patient_zhangh.tscn`，修改：
   - 节点名和 `patient_id` / `npc_name` 导出变量
   - 精灵纹理指向新目录

3. **编写对话**：在 `scripts/patient.gd` 中添加：
   - `_init_patient_data()` 的 `match patient_id` 分支：初始情绪、认知扭曲、BattleEngine 数据、隐藏 Schema
   - `_build_dialogue()` 的对话分支：多轮对话 + 选择点 + 评分
   - `_show_completion_dialogue()` 的结局分支

4. **注册章节**：在 `scripts/autoload/game_manager.gd` 的 `_chapter_defs` 中添加章节定义

5. **放入世界**：在 `scenes/game_world.tscn` 中 instance 新患者场景，在 `map_builder.gd` 的 `_reposition_characters()` 中设置初始位置

6. **房间映射**：在 `scripts/autoload/room_manager.gd` 的 `_chapter_to_room` 和 `_room_configs` 中配置

### 添加新技能

在 `scripts/autoload/battle_engine.gd` 的 `_effectiveness` 字典中添加新技能行，并在 `scripts/autoload/skill_tree.gd` 中配置技能线。

### 添加新地图/房间

1. 创建 `scenes/rooms/room_xxx.tscn`（参考现有房间场景）
2. 在 `room_manager.gd` 的 `_room_configs` 中注册
3. 在 `map_builder.gd` 中可添加对应的 TileMap 重绘逻辑

### 修改评分阈值

编辑 `scripts/autoload/scoring_system.gd` 中的 `get_grade()` 函数和 `scripts/autoload/game_manager.gd` 中章节的 `min_grade`。

---

## 测试

测试框架为纯 GDScript 实现，无需第三方依赖。

### 运行方式

```bash
# 方式 1：命令行（推荐）
rm -f ~/.local/share/godot/app_userdata/CBT\ Therapy\ Simulator/save_data.json
godot --headless --path . --script tests/test_runner.gd

# 方式 2：编辑器内
# 打开 tests/test_scene.tscn，按 F6 运行当前场景
```

### 测试覆盖

| # | 测试名称 | 覆盖内容 |
|---|---|---|
| 1 | 患者档案初始化 | 3位患者初始情绪/认知扭曲 |
| 2-4 | 林小雨 S1 优/差/完整 | 对话生成+评分+反馈 |
| 5 | 林小雨 S2 对话完整 | 多选择点结构验证 |
| 6 | 林小雨 S3 认知转变 | 后续对话进度 |
| 7 | 林小雨治疗完成 | 结局对话多分支 |
| 8 | 张浩 S1 完整流程 | 第二患者独立验证 |
| 9 | 评分系统5维度 | 评级计算+反馈生成 |
| 10 | 完整游戏流程 | 3次治疗→解锁→章节推进 |
| 11 | 信任/羁绊系统 | 增减/上下界/等级 |
| 12 | 情绪状态机 | active→recovering→resilient |
| 13 | CBT技能树 | 升级/倍率/奖励 |
| 14 | 成就徽章 | 解锁/去重/条件触发 |
| 15 | 治疗日记 | 记录/检索 |
| 16 | 战斗引擎初始化 | 患者 BattleEngine 数据 |
| 17 | 战斗引擎属性克制 | ×3.0 拔群 / ×0.1 无效 |
| 18 | 战斗引擎状态转换 | GUARDED→TESTING / 反效果→RESISTANT |
| 19 | 战斗引擎Schema发现 | 隐藏信念揭示 |

### 注意事项

- 测试前务必清除存档，否则 `completed_chapters` 污染会导致测试失败
- `--headless` 模式下 `process_frame` 和 `create_timer` 不触发，测试用 `set_process(false)` + `call_deferred()` 规避
- NPC 的 `AnimatedSprite2D` 在测试中会报错（无 sprite 节点），不影响测试结果

---

## 已知限制

- **音频为空**：`audio/bgm/` 和 `audio/sfx/` 尚未填充，游戏无声
- **房间场景未实际使用**：`scenes/rooms/` 中的场景为独立装饰场景，房间切换仅改变背景色
- **情绪NPC复用精灵**：4个情绪NPC使用前台接待员精灵+颜色叠加
- **王美精灵为生成图**：基于林小雨精灵紫色调处理，非原创
- **无 .gitignore**：`.godot/` 和 `.import` 缓存文件未被忽略
- **终章（final_review）未实现完整对话**：`patient_id = "final_review"` 无对应场景
- **分辨率固定**：640×480 + 2x 缩放，未做自适应

---

## 许可证

本项目仅供学习和教育目的使用。
