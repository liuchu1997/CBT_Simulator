**English** | **[中文](./README.zh-CN.md)**

# CBT Therapy Simulator

A Pokemon-style JRPG educational simulation game based on **Cognitive Behavioral Therapy (CBT)**. Play as a psychotherapist, engage in dialogue with virtual patients, choose treatment strategies, and help patients identify cognitive distortions to achieve psychological growth.

**Engine:** Godot 4.4 | **Language:** GDScript | **Resolution:** 640x480 pixel art

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Gameplay Flow](#gameplay-flow)
- [Controls](#controls)
- [Extension Guide](#extension-guide)
- [Testing](#testing)
- [Known Limitations](#known-limitations)

---

## Features

| Feature | Description |
|---|---|
| **3 Patients** | Lin Xiaoyu (depression), Zhang Hao (anxiety), Wang Mei (personalization) - 5 therapy sessions each |
| **7-State Emotion System** | GUARDED -> TESTING -> OPENING_UP -> EMOTIONALLY_FLOODED -> RESISTANT -> REFLECTIVE -> INSIGHT |
| **Type Effectiveness Chart** | 7 CBT skills x 7 emotional states, Pokemon-style effectiveness (x3.0 super effective / x0.1 no effect) |
| **Hidden Schema Discovery** | 3 hidden core beliefs (schemas) per patient, gradually revealed during therapy |
| **5-Dimension Scoring** | Empathy, Active Listening, Socratic Questioning, Cognitive Restructuring, Rapport Building |
| **3-Branch Skill Tree** | Cognitive Restructuring / Behavioral Activation / Empathic Listening, 4 levels each, unlocks advanced dialogue options |
| **Chapter-Driven Progression** | 4 chapters + final chapter, progressively unlock patients with skill level and grade requirements |
| **Emotion NPC Tutorials** | 4 emotion sprites (Anger/Sadness/Fear/Joy) teach players to identify cognitive distortions |
| **Trust & Bond System** | Trust level affects dialogue content and endings, with decay mechanics |
| **Multiple Endings** | Endings dynamically generated based on grade (S/A/B/C/D), trust, and BattleEngine state |
| **Save System** | Auto-save to `user://save_data.json`, manual save and reset supported |

---

## Quick Start

### Requirements

- **Godot 4.4.1+** ([Download](https://godotengine.org/download))
- OS: Windows / macOS / Linux
- No additional dependencies

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd CBT_Simulator

# 2. Open with Godot Editor
#    Option A: Command line
godot --path .

#    Option B: Godot Editor -> Scan -> Import project -> Double-click to open

# 3. First launch auto-generates .godot/ cache and .import files (~30 seconds)

# 4. Run the game
#    Press F5 in editor, or command line:
godot --path .
```

### Running Tests

```bash
# Clear save data (avoid test data interference)
rm -f ~/.local/share/godot/app_userdata/CBT\ Therapy\ Simulator/save_data.json

# Run 18 automated tests
godot --headless --path . --script tests/test_runner.gd
```

Expected output: `Total: 18 | Passed: 18 | Failed: 0 >>> ALL TESTS PASSED! <<<`

---

## Project Structure

```
CBT_Simulator/
├── project.godot                    # Project config (autoloads / input mapping / physics layers)
├── theme.tres                       # Default UI theme
├── icon.svg                         # Project icon
│
├── assets/
│   └── sprites/
│       ├── characters/              # Character pixel sprites (8 directions x 2 states each)
│       │   ├── therapist/           # Player therapist
│       │   ├── lin_xiaoyu/          # Lin Xiaoyu (depression patient)
│       │   ├── zhang_hao/           # Zhang Hao (anxiety patient)
│       │   ├── wang_mei/            # Wang Mei (personality patient)
│       │   └── npc_receptionist/    # Receptionist NPC
│       ├── tilesets/
│       │   └── indoor.png           # Indoor map tileset
│       └── ui/                      # UI assets (placeholder)
│
├── audio/
│   ├── bgm/                         # Background music (placeholder)
│   └── sfx/                         # Sound effects (placeholder)
│
├── fonts/
│   └── NotoSansSC-Regular.otf       # Chinese font
│
├── scenes/
│   ├── main_menu.tscn               # Main menu scene (entry point)
│   ├── game_world.tscn              # Game world (map + characters + HUD)
│   ├── characters/                  # Character PackedScenes
│   │   ├── player.tscn              #   Player (CharacterBody2D)
│   │   ├── patient_linxy.tscn       #   Lin Xiaoyu
│   │   ├── patient_zhangh.tscn      #   Zhang Hao
│   │   ├── patient_wangmei.tscn     #   Wang Mei
│   │   ├── npc_receptionist.tscn    #   Receptionist
│   │   └── emotion_*.tscn           #   4 Emotion NPCs
│   ├── rooms/                       # Room scenes
│   │   ├── room_depression.tscn     #   Depression therapy room (blue)
│   │   ├── room_anxiety.tscn        #   Anxiety therapy room (orange)
│   │   ├── room_personality.tscn    #   Personality therapy room (purple)
│   │   └── room_crisis.tscn         #   Crisis intervention room (red)
│   └── ui/                          # UI components
│       ├── dialogue_box.tscn        #   Dialogue box
│       ├── battle_hud.tscn          #   Battle panel (alliance/stats/state)
│       ├── score_report.tscn        #   Score report
│       ├── skill_tree.tscn          #   Skill tree
│       ├── journal.tscn             #   Therapy journal
│       ├── pause_menu.tscn          #   Pause menu
│       ├── chapter_complete.tscn    #   Chapter completion
│       ├── patient_profile_ui.tscn  #   Patient profile
│       ├── achievement_popup.tscn   #   Achievement popup
│       ├── tutorial_card.tscn       #   Tutorial card
│       └── tutorial.tscn            #   Tutorial screen
│
├── scripts/
│   ├── main_menu.gd                 # Main menu logic
│   ├── map_builder.gd               # Map building (TileMap painting + character placement)
│   ├── player_controller.gd         # Player movement + interaction
│   ├── patient.gd                   # Patient dialogue tree (734 lines, core script)
│   ├── npc_base.gd                  # NPC base class
│   ├── emotion_npc.gd               # Emotion teaching NPC
│   ├── autoload/                    # Global singletons (8)
│   │   ├── game_manager.gd          #   Game state / save / chapters / unlocks
│   │   ├── battle_engine.gd         #   Emotion state machine + type effectiveness + schema discovery
│   │   ├── scoring_system.gd        #   5-dimension scoring engine
│   │   ├── dialogue_manager.gd      #   Dialogue queue + choice system
│   │   ├── skill_tree.gd            #   3-branch skill tree + score multipliers
│   │   ├── room_manager.gd          #   Room switching + chapter mapping
│   │   ├── cbt_tutorial.gd          #   Tutorial trigger system
│   │   └── font_loader.gd           #   Chinese font auto-loading
│   ├── rooms/
│   │   └── room_base.gd             # Room base class
│   └── ui/                          # UI scripts (matching scenes/ui/)
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
    ├── test_runner.gd               # Test launcher (SceneTree mode)
    ├── test_all.gd                  # 18 test cases
    └── test_scene.tscn              # Test scene
```

---

## Architecture

### Autoload Global Singletons (load order)

| Singleton | Script | Lines | Responsibility |
|---|---|---|---|
| `GameManager` | `autoload/game_manager.gd` | 455 | Central game state: session management, patient unlocking, chapter progression, save/load, trust/bond, achievements |
| `ScoringSystem` | `autoload/scoring_system.gd` | 88 | 5-dimension scoring: empathy/listening/socratic/cognitive restructuring/rapport, generates grades (S/A/B/C/D) |
| `DialogueManager` | `autoload/dialogue_manager.gd` | 114 | Dialogue queue: text display, choice menus, callbacks, cooldown |
| `SkillTree` | `autoload/skill_tree.gd` | 90 | 3 skill branches (cognitive/behavioral/empathic), 4 levels, score multipliers |
| `CbtTutorial` | `autoload/cbt_tutorial.gd` | 67 | First-time trigger tutorial cards |
| `FontLoader` | `autoload/font_loader.gd` | 18 | Recursively applies NotoSansSC Chinese font |
| `BattleEngine` | `autoload/battle_engine.gd` | 320 | 7-state emotion FSM, skill x state type effectiveness, schema discovery |
| `RoomManager` | `autoload/room_manager.gd` | 84 | 5-room management, patient-room mapping, background color switching |

### Core Signal Flow

```
Player presses Space to interact
  -> patient.gd.on_interact()
    -> DialogueManager.start_dialogue()          # Display dialogue
    -> Player chooses -> BattleEngine.apply_skill()  # Calculate type effectiveness
      -> alliance_changed / state_changed / battle_effect / schema_discovered
    -> ScoringSystem.record_choice()             # Record score
  -> patient.gd.end_session()
    -> GameManager.end_session()                  # Update progress
    -> GameManager.check_chapter_completion()     # Check chapter completion
      -> chapter_completed / patient_unlocked
    -> RoomManager.return_to_lobby()              # Return to lobby
```

### Physics Collision Layers

| Layer | Name | Purpose |
|---|---|---|
| 1 | player | Player character |
| 2 | npc | NPCs / patients |
| 3 | walls | Wall collision |
| 4 | objects | Furniture / object collision |

### Emotion State Machine (BattleEngine)

```
              Good skill                Good skill
  GUARDED ──────────→ TESTING ──────────→ OPENING_UP
     │                                      │  │
     │Bad skill                  Good skill │  │Emotional flooding
     ↓                         ┌────────────┘  ↓
  RESISTANT ←──────────────  REFLECTIVE ←── EMOTIONALLY_FLOODED
                               │
                               │Good skill
                               ↓
                            INSIGHT
```

### Type Effectiveness Chart (Skill x Emotional State, partial)

| Skill | GUARDED | TESTING | REFLECTIVE | RESISTANT |
|---|---|---|---|---|
| reflection | **x3.0 Super Effective** | x2.0 | x1.0 | x2.0 |
| cognitive_restructuring | **x0.1 No Effect** | x1.5 | x2.5 | x0.5 |
| validation | x2.0 | x1.5 | x1.0 | x2.5 |
| behavioral_activation | x0.5 | x1.0 | x2.0 | x0.5 |

> Design philosophy: Use empathic/reflection skills to "break through" patient defensiveness; cognitive restructuring is only effective when patients are in reflective states.

---

## Gameplay Flow

```
Main Menu -> Click "Start Game"
  -> game_world.tscn (40x30 tile map)
    -> WASD to move character
    -> Approach NPC -> Space to interact
      -> Emotion NPCs: CBT knowledge quizzes (correct +2 / wrong -1)
      -> Patients: Multi-turn therapy dialogue (with choice branches)
        -> Each choice triggers BattleEngine type calculation
        -> Score report (5 dimensions + grade + feedback)
    -> Complete 3 sessions -> Chapter grade check
      -> Pass -> Unlock next patient + new chapter
      -> Fail -> Can retry
  -> ESC to pause (save / reset / return to menu)
```

### Chapter Progression

| Chapter | Patient | Sessions | Min Grade | Skill Requirements |
|---|---|---|---|---|
| Ch.1: First Steps | Lin Xiaoyu (depression) | 3 | D | None |
| Ch.2: Mask of Anxiety | Zhang Hao (anxiety) | 3 | D | Cognitive Lv.1 + Empathic Lv.1 |
| Ch.3: Self-Attribution | Wang Mei (personalization) | 3 | C | Cognitive Lv.2 + Empathic Lv.2 |
| Final: Therapist's Growth | Comprehensive Review | 1 | B | Cognitive Lv.3 + Behavioral Lv.2 + Empathic Lv.3 |

### Grade Thresholds

| Score | Grade |
|---|---|
| >=12 | S |
| >=10 | A |
| >=7 | B |
| >=4 | C |
| <4 | D |

---

## Controls

| Key | Action | Description |
|---|---|---|
| W/A/S/D or Arrow Keys | Move | Grid-based movement, 16px steps |
| Space or J | Interact | Talk to NPC in facing direction |
| K | Skill Tree | Open/close skill upgrade panel |
| J | Journal | View therapy journal |
| I | Profile | View patient profile |
| ESC | Pause | Pause menu (save / reset / quit) |

---

## Extension Guide

### Adding a New Patient

1. **Create sprites**: Add a new directory under `assets/sprites/characters/` with 8 16x16 PNGs:
   - `idle_down.png`, `idle_up.png`, `idle_left.png`, `idle_right.png`
   - `walk_down.png`, `walk_up.png`, `walk_left.png`, `walk_right.png`
   - Open Godot editor to auto-generate `.import` files

2. **Create scene**: Copy `scenes/characters/patient_zhangh.tscn`, modify:
   - Node name and `patient_id` / `npc_name` export variables
   - Sprite texture paths to new directory

3. **Write dialogue**: Add to `scripts/patient.gd`:
   - `_init_patient_data()` match branch: initial emotions, cognitive distortions, BattleEngine data, hidden schemas
   - `_build_dialogue()` dialogue branch: multi-turn dialogue + choice points + scoring
   - `_show_completion_dialogue()` ending branch

4. **Register chapter**: Add chapter definition in `scripts/autoload/game_manager.gd` `_chapter_defs`

5. **Place in world**: Instance new patient scene in `scenes/game_world.tscn`, set initial position in `map_builder.gd` `_reposition_characters()`

6. **Room mapping**: Configure in `scripts/autoload/room_manager.gd` `_chapter_to_room` and `_room_configs`

### Adding New Skills

Add new skill rows in `scripts/autoload/battle_engine.gd` `_effectiveness` dictionary, and configure skill branches in `scripts/autoload/skill_tree.gd`.

### Adding New Maps/Rooms

1. Create `scenes/rooms/room_xxx.tscn` (reference existing room scenes)
2. Register in `room_manager.gd` `_room_configs`
3. Optionally add TileMap redraw logic in `map_builder.gd`

### Modifying Grade Thresholds

Edit the `get_grade()` function in `scripts/autoload/scoring_system.gd` and `min_grade` in chapter definitions in `scripts/autoload/game_manager.gd`.

---

## Testing

The test framework is pure GDScript with no third-party dependencies.

### How to Run

```bash
# Option 1: Command line (recommended)
rm -f ~/.local/share/godot/app_userdata/CBT\ Therapy\ Simulator/save_data.json
godot --headless --path . --script tests/test_runner.gd

# Option 2: In editor
# Open tests/test_scene.tscn, press F6 to run current scene
```

### Test Coverage

| # | Test Name | Coverage |
|---|---|---|
| 1 | Patient Profile Init | 3 patients' initial emotions / cognitive distortions |
| 2-4 | Lin Xiaoyu S1 Best/Worst/Full | Dialogue generation + scoring + feedback |
| 5 | Lin Xiaoyu S2 Dialogue | Multi-choice-point structure validation |
| 6 | Lin Xiaoyu S3 Cognitive Shift | Progression dialogue |
| 7 | Lin Xiaoyu Completion | Multiple ending dialogue branches |
| 8 | Zhang Hao S1 Full Flow | Second patient independent verification |
| 9 | Scoring System 5D | Grade calculation + feedback generation |
| 10 | Full Game Flow | 3 sessions -> unlock -> chapter progression |
| 11 | Trust/Bond System | Increase/decrease / bounds / levels |
| 12 | Emotion State Machine | active -> recovering -> resilient |
| 13 | CBT Skill Tree | Upgrade / multipliers / rewards |
| 14 | Achievement Badges | Unlock / deduplication / condition triggers |
| 15 | Therapy Journal | Record / retrieval |
| 16 | Battle Engine Init | Patient BattleEngine data |
| 17 | Battle Engine Effectiveness | x3.0 super effective / x0.1 no effect |
| 18 | Battle Engine State Transition | GUARDED->TESTING / backfire->RESISTANT |
| 19 | Battle Engine Schema Discovery | Hidden belief revelation |

### Notes

- Always clear save data before testing; `completed_chapters` pollution will cause test failures
- `process_frame` and `create_timer` don't fire in `--headless` mode; tests use `set_process(false)` + `call_deferred()` as workaround
- NPC `AnimatedSprite2D` errors in tests (no sprite nodes) do not affect test results

---

## Known Limitations

- **No audio**: `audio/bgm/` and `audio/sfx/` are empty; game is silent
- **Room scenes not fully utilized**: Scenes in `scenes/rooms/` are standalone decorative scenes; room switching only changes background color
- **Emotion NPCs reuse sprites**: 4 emotion NPCs use receptionist sprites with color overlay
- **Wang Mei sprites are generated**: Purple-tinted versions of Lin Xiaoyu sprites, not original art
- **Final chapter incomplete**: `patient_id = "final_review"` has no corresponding scene
- **Fixed resolution**: 640x480 + 2x zoom, no adaptive layout

---

## License

This project is for educational and learning purposes only.
