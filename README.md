# 🗡️ Guardians Fall — 2D Action Adventure
## Godot 4 | Press Play Hackathon 2026 | Constructor University Bremen

---

## 📖 Project Overview
**Guardians Fall** is a top-down 2D action game featuring tight combat, procedural-style map generation (physics-based), and intense horde management. This repository currently contains the **fully completed Level 2 (The Iron Mines)**.

### 🚀 Key Technical Features
- **Modular Level Architecture**: Scripts are designed to be attached to any TileMap to instantly add walls, collision, and enemy spawning.
- **Physics-Based Map Generation**: Automatic conversion of TileMap edges into solid physics bodies.
- **Intense Combat**: AOE (Area of Effect) sword attacks, screen shake, and knockback.
- **Horde AI**: Scalable enemy spawning (up to 60+ entities) with avoidance logic to prevent stacking.
- **Global State Management**: Persistent hearts/lives and health system across scenes via `GameManager`.

---

## 🗺️ Level 2: The Iron Mines (Status: COMPLETE)
Level 2 is a combat-heavy maze where the player must fight through a massive horde of 60 enemies to reach the stairs.

### Objectives:
1. Survive the initial horde.
2. Navigate the maze while managing stamina (Sprint/Dash).
3. Reach the **Stairs** at the end of the map to trigger **Victory**.

---

## 🎮 Controls

| Key | Action | Description |
|---|---|---|
| **WASD / Arrows** | Move | 8-way directional movement |
| **Shift** | Sprint | Increases speed significantly |
| **Space** | Dash | Quick tactical burst in movement direction |
| **F / Left Click** | Attack | AOE sword swing (hits all enemies in range) |
| **ESC** | Pause | (Game pauses automatically on Death/Win) |

---

## 🧱 File Structure

```
res://
├── assets/                    # Shared visual and audio assets
│   ├── sprites/
│   │   ├── player/            # Shared player sprites
│   │   └── enemies/           # Organized goblin/skeleton sprites
│   └── audio/
├── levels/
│   ├── level_1/               # (Reserved for teammate)
│   └── level_2/               # Current Level (The Iron Mines)
│       ├── scenes/
│       │   ├── entities/      # Level-specific player/enemies
│       │   └── maps/          # Level-specific TileMaps
│       └── scripts/
│           ├── player/        # Level-specific movement/physics
│           ├── enemies/       # Level-specific AI
│           └── managers/      # Level-specific systems
├── scripts/
│   └── global/                # Shared systems (GameManager)
└── project.godot
```

---

## 🛠️ Modular Systems (Guide for Level 1)
All scripts are **Export-Ready**. To use them in a new level:

1. **MapBoundary.gd**: 
   - Attach this to any `TileMap`.
   - In the Inspector, set your Wall Tile IDs.
   - It will automatically generate collision polygons for your walls and a "Void" boundary.
2. **WaveSpawner.gd**: 
   - Attach to any Node in your scene.
   - Set `Max Enemies` and `Spawn Interval` in the Inspector.
   - It automatically finds the TileMap and spawns enemies on floor tiles.
3. **stairs_area.gd**:
   - Attach to an `Area2D` over your exit.
   - It will automatically trigger the "Victory" sequence and pause the game.

---

## 🧪 Current Game Logic
- **Health**: 200 HP. Regeneration on scene reload.
- **Lives**: 3 Hearts. Losing all hearts triggers **Game Over**.
- **Enemy Scaling**: 
  - **Skeletons**: High health (40 HP), slower speed.
  - **Goblins**: Low health (20 HP), fast speed.
- **Combat**: 15 Damage per swing. Hits every enemy in an 80x80 radius.
- **Victory Condition**: Reaching the `Area2D` stairs.

---

## 👥 Team
- **Project Location**: Constructor University Bremen
- **Hackathon**: Press Play 2026
- **Hosted by**: DCS & GDG on Campus
