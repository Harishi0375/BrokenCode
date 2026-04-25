# 🗡️ Guardians Fall — 2D Story-Driven Action Game
## Built with Godot 4 | Press Play Hackathon 2026 | Constructor University Bremen

---

## 📖 Game Overview

**Guardians Fall** is a 2D story-driven action-adventure game built in Godot 4.
You play as the last surviving guardian of a fallen lineage. Your village betrayed 
you — selling a loved one to a dark entity in exchange for immortality. The pact 
backfired: immortality became an undead curse, and the world is collapsing into chaos.

Your mission: escape, survive, and confront the dark entity responsible.

---

## 🎮 Genre & Style
- **Genre:** 2D Story-Driven Action Adventure
- **Perspective:** Top-down 2D
- **Engine:** Godot 4
- **Language:** GDScript
- **Platform:** HTML5/WebGL (itch.io), Desktop

---

## 🗺️ Game Structure — Maps & Levels

The game is divided into 3 maps, each with its own story context,
mechanics, and objectives. Maps are loaded sequentially as the 
player completes each one.

---

### 🗺️ MAP 1 — The Betrayal (The Village)

**Story Context:**
The village is celebrating, but the atmosphere is heavy and dark.
The player starts imprisoned in a cell. The villagers have betrayed
the guardian lineage, selling a loved one to a dark entity.

**Objectives:**
1. Escape the prison cell
2. Solve the Pre-Weapon Puzzle:
   - Sabotage the village bell mechanism to create a diversion
   - Steal the armory key from a distracted guard
3. Fight through corrupted villagers trying to stop your escape
4. Exit the village to reach the Desolate Lands

**Mechanics:**
- Stealth movement near guards
- Puzzle interaction (bell mechanism sabotage)
- Key item pickup (armory key)
- Basic melee combat against corrupted villagers
- Exit trigger to load Map 2

**Key Objects/Entities:**
- Player (imprisoned, no weapon at start)
- Prison cell door (locked)
- Bell mechanism (interactive puzzle object)
- Guard NPC (distracted by bell diversion)
- Armory key (item pickup)
- Corrupted villager enemies (melee attackers)
- Village exit trigger zone

---

### 🗺️ MAP 2 — The Desolate Lands (The Zombies)

**Story Context:**
Outside the village, the forest is crawling with those who 
"succeeded" in the ritual. They cannot die — their souls are 
trapped in undead bodies. Combat is completely useless here.

**Objectives:**
1. Sprint and maneuver through the zombie-infested forest
2. Use the environment to avoid and outrun zombies
3. Find bandages to treat a critical wound slowing movement
4. Reach the entrance to the Iron Mines

**Mechanics:**
- NO combat in this map — zombies cannot be killed
- Sprint mechanic (tap shift to run, drains stamina)
- Movement speed penalty (player is wounded at start)
- Environmental navigation (climbing, obstacles, hiding spots)
- Bandage item pickup (restores movement speed to normal)
- Zombies follow player aggressively but can be outmaneuvered
- Exit trigger to load Map 3

**Key Objects/Entities:**
- Player (wounded, slow movement speed)
- Zombie enemies (unkillable, aggressive followers)
- Environmental obstacles (trees, rocks, fallen logs to navigate)
- Bandage pickup item (restores full movement speed)
- Hidden paths and climbable terrain
- Mine entrance exit trigger zone

---

### 🗺️ MAP 3 — The Iron Mines (The Goblins)

**Story Context:**
To reach the dark entity's castle, the player must cross the 
Iron Mines — a territory ruled by scavenger goblins who attack
on sight.

**Objectives:**
1. Find the hidden lever to reactivate the industrial elevator
2. Locate stashed dynamite to clear a rock wall blocking the path
3. Steal a Vision Gem to navigate the total darkness of the exit tunnel
4. Reach the castle entrance

**Mechanics:**
- Goblin enemies (melee attackers, patrol routes)
- Interactive lever puzzle (find and pull to activate elevator)
- Elevator platform (moves player between mine levels)
- Dynamite item pickup + destructible rock wall
- Vision Gem pickup (enables visibility in dark tunnel)
- Dark tunnel section (zero visibility without Vision Gem)
- Exit trigger to Castle (future map)

**Key Objects/Entities:**
- Player (full combat ability restored)
- Goblin enemies (patrol routes, attack on sight)
- Hidden lever (interactive object)
- Industrial elevator platform
- Stashed dynamite (item pickup)
- Destructible rock wall
- Vision Gem (item pickup)
- Dark tunnel section
- Castle entrance exit trigger

---

## 🧱 Project File Structure

```
res://
├── scenes/
│   ├── maps/
│   │   ├── map_2/
│   │   │   ├── Map.tscn
│   │   │   ├── base_layer_2.tscn
│   │   │   ├── walls_1.tscn
│   │   │   └── tileset.png
│   │   └── CatacombsGenerator.tscn
│   ├── entities/
│   │   ├── Player.tscn
│   │   ├── enemies/
│   │   │   ├── CorruptedVillager.tscn
│   │   │   ├── Zombie.tscn
│   │   │   └── Goblin.tscn
│   │   └── npcs/
│   │       └── Guard.tscn
│   ├── objects/
│   │   ├── BellMechanism.tscn
│   │   ├── Elevator.tscn
│   │   ├── RockWall.tscn
│   │   └── DarkTunnel.tscn
│   ├── items/
│   │   ├── ArmoryKey.tscn
│   │   ├── Bandage.tscn
│   │   ├── Dynamite.tscn
│   │   └── VisionGem.tscn
│   └── ui/
│       ├── HUD.tscn
│       ├── MainMenu.tscn
│       └── GameOver.tscn
├── scripts/
│   ├── player/
│   │   ├── Player.gd
│   │   ├── PlayerMovement.gd
│   │   ├── PlayerCombat.gd
│   │   └── PlayerInventory.gd
│   ├── enemies/
│   │   ├── BaseEnemy.gd
│   │   ├── CorruptedVillager.gd
│   │   ├── Zombie.gd
│   │   └── Goblin.gd
│   ├── objects/
│   │   ├── BellMechanism.gd
│   │   ├── Elevator.gd
│   │   ├── RockWall.gd
│   │   └── DarkTunnel.gd
│   ├── items/
│   │   ├── BaseItem.gd
│   │   ├── ArmoryKey.gd
│   │   ├── Bandage.gd
│   │   ├── Dynamite.gd
│   │   └── VisionGem.gd
│   ├── managers/
│   │   ├── GameManager.gd
│   │   ├── DungeonGenerator.gd
│   │   ├── MapManager.gd
│   │   └── UIManager.gd
│   └── ui/
│       ├── HUD.gd
│       └── MainMenu.gd
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   ├── enemies/
│   │   ├── environment/
│   │   ├── items/
│   │   └── ui/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── fonts/
└── project.godot
```

---

## ⚙️ Core Systems to Implement

### 1. Player System
- Top-down movement (WASD / Arrow keys)
- Sprint mechanic (Shift key, stamina based)
- Health system (health bar on HUD)
- Movement speed modifier (wounded state in Map 2)
- Melee attack (disabled in Map 2)
- Inventory system (holds key items)
- Interaction system (press E to interact with objects)

### 2. Enemy System (Base)
- Base enemy class all enemies inherit from
- Health, damage, speed stats
- Basic pathfinding toward player (NavigationAgent2D)
- Death behavior (queue_free or freeze for zombies)

### 3. Enemy Types

**Corrupted Villager (Map 1):**
- Can be killed by player attack
- Blocks exit path
- Melee attack on contact

**Zombie (Map 2):**
- CANNOT be killed (invincible)
- Aggressively follows player
- Damages player on contact
- Fast enough to catch player if not sprinting

**Goblin (Map 3):**
- Can be killed
- Patrols set route
- Attacks player on sight (detection radius)
- Drops nothing (just clears path)

### 4. Item System
- Base item class
- Pickup on player contact (Area2D)
- Added to player inventory
- Each item has unique effect when picked up:
  - ArmoryKey → unlocks armory door
  - Bandage → restores movement speed
  - Dynamite → used on rock wall interaction
  - VisionGem → enables visibility in dark tunnel

### 5. Puzzle System

**Bell Mechanism (Map 1):**
- Player interacts (E key)
- Guard NPC enters distracted state
- Armory key becomes accessible

**Elevator (Map 3):**
- Inactive by default
- Hidden lever activates it
- Platform moves player vertically between mine floors

**Rock Wall (Map 3):**
- Blocks path
- Destroyed only if player has Dynamite in inventory
- Player interacts with wall → checks inventory → triggers destruction

**Dark Tunnel (Map 3):**
- Visibility set to near zero (CanvasModulate or Light2D)
- If player has VisionGem → visibility restored
- Without VisionGem → player cannot navigate

### 6. Map Manager
- Handles transitions between maps
- Saves player state (health, inventory) between maps
- Loads next map via get_tree().change_scene_to_file()
- Exit trigger zones (Area2D) at end of each map

### 7. HUD (UI)
- Health bar (top left)
- Stamina bar (top left, below health)
- Inventory display (shows collected key items)
- Current map/chapter title display
- Interaction prompt ("Press E to interact")

### 8. Game Manager (Singleton/Autoload)
- Tracks current map
- Tracks player health, inventory across scenes
- Handles game over condition
- Handles game win condition

---

## 🕹️ Controls

| Key | Action |
|---|---|
| WASD / Arrow Keys | Move |
| Shift | Sprint (uses stamina) |
| E | Interact with objects |
| Left Click / Space | Attack (when enabled) |
| ESC | Pause menu |

---

## 🚀 Implementation Priority (Build Order)

Start with this order — do not skip ahead:

1. [x] Player movement (top-down WASD)
2. [x] Setup custom unified TileMap (tile_map.tscn)
3. [x] Integrate Player and Camera tracking into Map
4. [x] Player health system + HUD health bar
5. [x] Basic melee attack
6. [x] One enemy that chases player (Skeleton/Goblin)
7. [x] Enemy takes damage and dies
8. [x] Player takes damage from enemy contact
9. [ ] Item pickup system (Base item)
10. [ ] Map transition system (exit trigger → load next scene)
11. [ ] Map 1 full implementation
12. [ ] Map 2 full implementation (zombie + sprint + bandage)
13. [ ] Map 3 full implementation (goblins + puzzles)
14. [ ] Main Menu scene
15. [ ] Game Over scene

---

## 📝 Notes for Implementation

- All maps are 2D top-down perspective
- Use CharacterBody2D for player and all enemies
- Use Area2D for item pickups and exit triggers
- Use NavigationRegion2D + NavigationAgent2D for enemy pathfinding
- Use a GameManager autoload singleton to persist data between scenes
- Stamina recharges when not sprinting
- Player speed values:
  - Normal: 200
  - Wounded (Map 2 start): 120
  - Sprinting: 320
- Zombie speed: 140 (faster than wounded player, slower than sprinting)
- Keep placeholder colored rectangles for sprites until art is ready

---

## 👥 Team
- Constructor University Bremen
- Press Play Hackathon 2026
- Hosted by DCS & GDG on Campus
