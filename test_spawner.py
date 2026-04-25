import re

with open("scripts/managers/WaveSpawner.gd", "r") as f:
    content = f.read()

content = content.replace("valid_spawn_cells.append(cell)", "valid_spawn_cells.append(cell)\n\t\tprint(\"Valid spawn cells found: \", valid_spawn_cells.size())")
content = content.replace("name = \"WaveSpawner\"", "name = \"WaveSpawner\"\n\tprint(\"WaveSpawner _ready called\")")

with open("scripts/managers/WaveSpawner.gd", "w") as f:
    f.write(content)
