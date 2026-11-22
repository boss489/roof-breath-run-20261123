class_name RoofLogic
extends RefCounted

const LEVELS := [
    {"end": 11, "weak": [[5, 7]]},
    {"end": 10, "weak": [[4, 7]]},
    {"end": 19, "weak": [[5, 7], [12, 15]]}
]
var stage := 0
var x := 0
var stamina := 4
var lives := 3
var ticks := 0
var mode := "TITLE"
var best := -1
var muted := false
var save_enabled := true

func is_weak(pos: int) -> bool:
    for interval in LEVELS[stage].weak:
        if pos >= interval[0] and pos <= interval[1]:
            return true
    return false

func start() -> void:
    stage = 0
    x = 0
    stamina = 4
    lives = 3
    ticks = 0
    mode = "PLAYING"

func retry_stage() -> void:
    x = 0
    stamina = 4
    mode = "PLAYING"

func die() -> void:
    lives -= 1
    stamina = 4
    x = 0
    mode = "FAILURE" if lives <= 0 else "PLAYING"

# Order: input -> bounds -> weak-entry validation/debit -> move -> exit.
func fixed_tick(direction: int, sprint: bool) -> String:
    if mode != "PLAYING":
        return "ignored"
    ticks += 1
    direction = clampi(direction, -1, 1)
    if direction == 0:
        if not sprint and not is_weak(x):
            var before := stamina
            stamina = mini(4, stamina + 1)
            return "rest" if before != stamina else "idle"
        return "idle"
    var target := x + direction
    if target < 0 or target > LEVELS[stage].end:
        return "edge"
    if is_weak(target):
        if not sprint or stamina < 1:
            die()
            return "failure" if mode == "FAILURE" else "fall"
        stamina -= 1
    x = target
    if x == LEVELS[stage].end:
        if stage == 2:
            mode = "SUCCESS"
            if best < 0 or ticks < best:
                best = ticks
                save_record()
            return "success"
        stage += 1
        x = 0
        stamina = 4
        return "stage"
    return "move"

func save_record() -> bool:
    if not save_enabled:
        return false
    var file := FileAccess.open("user://roof_record.json", FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify({"best": best, "muted": muted}))
    return true

func load_record() -> void:
    if not FileAccess.file_exists("user://roof_record.json"):
        return
    var file := FileAccess.open("user://roof_record.json", FileAccess.READ)
    if file == null:
        return
    var data = JSON.parse_string(file.get_as_text())
    if data is Dictionary:
        best = int(data.get("best", -1))
        muted = bool(data.get("muted", false))
