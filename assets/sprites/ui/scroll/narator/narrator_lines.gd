extends Node

# ── OPENING ──────────────────────────────
static func opening() -> Array:
    return [
        "You built this. You broke this. The only exit is the end screen.",
        "To escape, you must do the one thing you never managed from the outside — finish all three games.",
        "Not voices. Singular. Just one voice.",
        "No one important. Just the voice your games never had — since you clearly weren't going to add proper dialogue yourself."
    ]

# ── LEVEL 1 ──────────────────────────────
static func level1_death() -> Array:
    return [
        "How does it feel? Dying to your own creation?"
    ]

static func level1_complete() -> Array:
    return [
        "Congrats. Somehow you managed to pass the first game.",
        "...You thought that was it, didn't you? You thought you could just walk out after one level. How adorable."
    ]

# ── LEVEL 2 ──────────────────────────────
static func level2_death() -> Array:
    return [
        "How do you manage to die in your own game? Didn't you know this was coming?"
    ]

static func level2_complete() -> Array:
    return [
        "That took you embarrassingly long. But okay — congrats. I genuinely didn't think you'd make it out of there."
    ]

# ── ENDING ───────────────────────────────
static func ending() -> Array:
    return [
        "Wow. You actually did it. You escaped all three. That's genuinely impressive — for you.",
        "Tell me — was it hard? Facing your own bad decisions up close like that?",
        "There it is."
    ]