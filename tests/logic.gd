extends SceneTree
const Logic = preload("res://GameLogic.gd")
var checks := 0
func check(value: bool, message: String) -> void:
    checks += 1
    if not value:
        push_error("FAILED: " + message)
        quit(1)

func _initialize() -> void:
    var g = Logic.new()
    g.save_enabled = false
    g.start()
    check(g.mode == "PLAYING" and g.lives == 3, "start")
    check(g.fixed_tick(-1, false) == "edge" and g.x == 0, "bounds")
    for i in 4: g.fixed_tick(1, false)
    check(g.x == 4 and g.stamina == 4, "safe walk")
    check(g.fixed_tick(1, false) == "fall" and g.lives == 2 and g.x == 0, "weak no sprint")
    for i in 4: g.fixed_tick(1, false)
    for i in 3: g.fixed_tick(1, true)
    check(g.x == 7 and g.stamina == 1, "weak cost")
    g.fixed_tick(1, false)
    for i in 4: g.fixed_tick(0, false)
    check(g.stamina == 4, "rest cap")
    for i in 3: g.fixed_tick(1, false)
    check(g.stage == 1 and g.stamina == 4, "next stage")
    for i in 3: g.fixed_tick(1, false)
    for i in 4: g.fixed_tick(1, true)
    check(g.stamina == 0 and g.x == 7, "exact zero valid")
    g.fixed_tick(-1, true)
    check(g.x == 0 and g.lives == 1, "zero stamina entry falls")
    g.fixed_tick(1, false)
    g.fixed_tick(1, false)
    g.fixed_tick(1, false)
    check(g.fixed_tick(1, false) == "failure" and g.mode == "FAILURE", "three deaths fail")
    g.start()
    check(g.ticks == 0 and g.lives == 3 and g.stage == 0, "restart clears")
    for stage in 3:
        var end: int = Logic.LEVELS[stage].end
        for dest in range(1, end + 1):
            if stage == 2 and dest == 12:
                for r in 3: g.fixed_tick(0, false)
            var weak := false
            for span in Logic.LEVELS[stage].weak:
                if dest >= span[0] and dest <= span[1]: weak = true
            g.fixed_tick(1, weak)
        check(g.stage == mini(2, stage + 1), "replay stage %d" % stage)
    check(g.mode == "SUCCESS" and g.best == g.ticks, "complete and memory record")
    g.retry_stage()
    check(g.mode == "PLAYING" and g.x == 0 and g.stamina == 4, "retry")
    print("PASS %d checks; replay %d ticks; best %d" % [checks, g.ticks, g.best])
    quit()
