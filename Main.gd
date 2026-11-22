extends Node2D

const Logic = preload("res://GameLogic.gd")
const FONT = preload("res://assets/NotoSansKR.ttf")
const SKY := Color("#101b38")
const INK := Color("#0b142c")
const CREAM := Color("#fff3d6")
const CYAN := Color("#71dfd6")
const ORANGE := Color("#ff9d67")
var game = Logic.new()
var held: Dictionary = {}
var timer := 0.0
var visual_x := 0.0
var motion := 0.0
var effect := ""
var effect_age := 0.0
var sound: AudioStreamPlayer
var clock := 0.0

func _ready() -> void:
    game.load_record()
    sound = AudioStreamPlayer.new()
    add_child(sound)
    get_viewport().size_changed.connect(queue_redraw)
    queue_redraw()

func _process(delta: float) -> void:
    clock += delta
    effect_age += delta
    motion = minf(1.0, motion + delta / 0.16)
    if game.mode == "PLAYING":
        timer += delta
        while timer >= 0.2:
            timer -= 0.2
            var left := Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) or held.values().has("left")
            var right := Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) or held.values().has("right")
            var run := Input.is_key_pressed(KEY_SHIFT) or held.values().has("sprint")
            var dir := int(right) - int(left)
            var previous: int = game.x
            var result: String = game.fixed_tick(dir, run)
            if result == "move":
                visual_x = float(previous)
                motion = 0.0 if run else 0.35
                if run: _fx("dash")
            elif result == "rest": _fx("rest")
            elif result == "fall" or result == "failure":
                held.clear()
                visual_x = 0
                _fx("fall")
            elif result == "stage" or result == "success":
                held.clear()
                visual_x = 0
                _fx("clear")
    queue_redraw()

func _fx(kind: String) -> void:
    effect = kind
    effect_age = 0.0
    if game.muted: return
    var rate := 22050
    var samples := 2600
    var packed := PackedByteArray()
    packed.resize(samples * 2)
    var frequency := 680.0 if kind == "clear" else (155.0 if kind == "fall" else (460.0 if kind == "rest" else 310.0))
    for i in samples:
        var envelope := pow(1.0 - float(i) / samples, 2.0)
        var wave := sin(TAU * frequency * float(i) / rate) * envelope * 0.13
        var sample := int(clampf(wave, -1, 1) * 32767)
        packed.encode_s16(i * 2, sample)
    var audio := AudioStreamWAV.new()
    audio.format = AudioStreamWAV.FORMAT_16_BITS
    audio.mix_rate = rate
    audio.stereo = false
    audio.data = packed
    sound.stream = audio
    sound.play()

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if game.mode == "PLAYING":
                game.mode = "RESTART"
                held.clear()
            elif game.mode == "RESTART": game.mode = "PLAYING"
        elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
            _activate("primary")
        queue_redraw()
    if event is InputEventScreenTouch:
        var id: int = event.index + 100
        if event.pressed:
            var action := _hit(event.position)
            if action in ["left", "right", "sprint"]: held[id] = action
            else: _activate(action)
        else: held.erase(id)
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            var action := _hit(event.position)
            if action in ["left", "right", "sprint"]: held[0] = action
            else: _activate(action)
        else: held.erase(0)
    if event is InputEventScreenDrag and held.has(event.index + 100):
        var action := _hit(event.position)
        if action in ["left", "right", "sprint"]: held[event.index + 100] = action
        else: held.erase(event.index + 100)

func _activate(action: String) -> void:
    if action == "mute":
        game.muted = not game.muted
        game.save_record()
    elif game.mode == "TITLE" and action == "primary": game.mode = "TUTORIAL"
    elif game.mode == "TUTORIAL" and (action == "primary" or action in ["left", "right", "sprint"]):
        game.start()
        visual_x = 0
        timer = 0
    elif game.mode == "PLAYING" and action == "pause":
        game.mode = "RESTART"
        held.clear()
    elif game.mode == "RESTART":
        if action == "primary": game.retry_stage()
        elif action == "secondary": game.start()
        elif action == "back": game.mode = "PLAYING"
        held.clear()
        visual_x = float(game.x)
        timer = 0
    elif game.mode in ["SUCCESS", "FAILURE"] and action == "primary":
        game.start()
        visual_x = 0
        timer = 0
    _fx("click")
    queue_redraw()

func _hit(point: Vector2) -> String:
    var h := get_viewport_rect().size.y
    if Rect2(795, 20, 135, 65).has_point(point): return "mute"
    if game.mode == "PLAYING":
        if Rect2(20, 20, 150, 65).has_point(point): return "pause"
        for k in 3:
            if Rect2(35 + k * 310, h - 190, 270, 155).has_point(point): return ["left", "right", "sprint"][k]
    elif game.mode == "RESTART":
        if Rect2(175, h * 0.60, 610, 85).has_point(point): return "primary"
        if Rect2(175, h * 0.60 + 105, 610, 85).has_point(point): return "secondary"
        if Rect2(175, h * 0.60 + 210, 610, 70).has_point(point): return "back"
    elif Rect2(165, h * 0.72, 630, 110).has_point(point): return "primary"
    return ""

func text(value: String, x: float, y: float, size: int = 30, color: Color = CREAM, align: int = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1) -> void:
    var origin := x - width * 0.5 if align == HORIZONTAL_ALIGNMENT_CENTER and width > 0 else x
    draw_string(FONT, Vector2(origin, y), value, align, width, size, color)

func panel(box: Rect2, fill: Color, outline: Color = CYAN) -> void:
    draw_rect(box, fill, true)
    draw_rect(box, outline, false, 3.0)

func button(box: Rect2, label: String, active: bool = false, size: int = 35) -> void:
    panel(box, Color("#274568") if active else Color("#1c3353"), CYAN if active else Color("#567e97"))
    text(label, box.position.x + box.size.x * 0.5, box.position.y + box.size.y * 0.61, size, CREAM, HORIZONTAL_ALIGNMENT_CENTER, box.size.x - 12)

func _draw() -> void:
    var v := get_viewport_rect().size
    var h := v.y
    draw_rect(Rect2(Vector2.ZERO, v), SKY)
    draw_rect(Rect2(0, h * 0.61, 960, h * 0.39), INK)
    _skyline(h)
    if game.mode == "PLAYING" or game.mode == "RESTART": _play_scene(h)
    elif game.mode == "TITLE": _title(h)
    elif game.mode == "TUTORIAL": _tutorial(h)
    elif game.mode == "SUCCESS": _end_screen(h, true)
    elif game.mode == "FAILURE": _end_screen(h, false)
    button(Rect2(795, 20, 135, 65), "♪ 켬" if not game.muted else "♪ 끔", false, 22)

func _skyline(h: float) -> void:
    draw_circle(Vector2(744, h * 0.18), 64, Color("#fce5af"))
    draw_circle(Vector2(770, h * 0.155), 61, SKY)
    for i in 36:
        var sx := float((i * 311 + 41) % 945)
        var sy := float((i * 117 + 53) % int(maxf(280, h * 0.37)))
        draw_circle(Vector2(sx, sy), 1.7 + float(i % 3), Color("#a6b9d6", 0.45 + 0.2 * sin(clock * 1.5 + i)))
    for i in 15:
        var bx := float(i * 74 - 18)
        var bh := float(95 + ((i * 53) % 175))
        var by := h * 0.61 - bh
        draw_rect(Rect2(bx, by, 66, bh + 18), Color("#1b2c4c"))
        for row in 3:
            for col in 2:
                if (i + row * 2 + col) % 3 != 0:
                    draw_rect(Rect2(bx + 12 + col * 27, by + 18 + row * 32, 11, 15), Color("#d9ae75", 0.46))

func _roof(h: float, stage: int, hero_pos: float, stamina: int) -> void:
    var count: int = int(Logic.LEVELS[stage].end) + 1
    var cell := minf(67.0, 870.0 / count)
    var start := (960.0 - cell * count) / 2.0
    var roof_y := h * 0.47
    draw_line(Vector2(0, roof_y + 98), Vector2(960, roof_y + 98), Color("#182c47"), 14)
    for i in count:
        var px := start + i * cell
        var fragile := false
        for span in Logic.LEVELS[stage].weak:
            if i >= span[0] and i <= span[1]: fragile = true
        var tile := Rect2(px + 2, roof_y, cell - 4, 65)
        draw_rect(tile, Color("#744c4d") if fragile else Color("#c7e8e1"))
        draw_rect(Rect2(px + 2, roof_y + 61, cell - 4, 7), ORANGE if fragile else CYAN)
        if fragile:
            for slant in 4:
                var sx := px + 6 + slant * (cell - 12) / 4
                draw_line(Vector2(sx, roof_y + 13), Vector2(minf(sx + 18, px + cell - 5), roof_y + 38), ORANGE, 3)
        else:
            draw_line(Vector2(px + 9, roof_y + 15), Vector2(px + cell - 9, roof_y + 15), CREAM, 2)
        if i == Logic.LEVELS[stage].end:
            draw_rect(Rect2(px + cell * 0.36, roof_y - 84, cell * 0.32, 84), Color("#85e7d6"))
            draw_circle(Vector2(px + cell * 0.52, roof_y - 85), 12, CREAM)
    var hx := start + (lerpf(hero_pos, float(game.x), motion) + 0.5) * cell
    if effect == "dash" and effect_age < 0.15:
        draw_circle(Vector2(hx - 18, roof_y - 25), 20, Color(CYAN, 0.30))
    draw_colored_polygon(PackedVector2Array([Vector2(hx - 11, roof_y - 33), Vector2(hx - 42, roof_y - 39 - sin(clock * 13) * 5), Vector2(hx - 12, roof_y - 46)]), CREAM)
    draw_rect(Rect2(hx - 14, roof_y - 44, 28, 37), Color("#ffbd91"))
    draw_circle(Vector2(hx, roof_y - 57), 19, CREAM)
    draw_rect(Rect2(hx - 20, roof_y - 75, 40, 8), ORANGE)
    draw_circle(Vector2(hx + 6, roof_y - 57), 2.6, INK)
    if effect == "rest" and effect_age < 0.23:
        for i in 3: draw_circle(Vector2(hx - 20 + i * 19, roof_y - 90 - i * 11), 4, CYAN)
    if effect == "fall" and effect_age < 0.32:
        for i in 8:
            var a := float(i) * TAU / 8.0
            draw_rect(Rect2(hx + cos(a) * 55, roof_y + sin(a) * 50, 7, 7), ORANGE)

func _play_scene(h: float) -> void:
    _roof(h, game.stage, visual_x, game.stamina)
    button(Rect2(20, 20, 150, 65), "Ⅱ 메뉴", false, 25)
    text("지붕  %d / 3" % (game.stage + 1), 50, 146, 43)
    text("목숨  %s" % "♥".repeat(game.lives), 50, 198, 35, ORANGE)
    text("기력", 600, 146, 35)
    for i in 4:
        panel(Rect2(688 + i * 60, 112, 46, 36), CYAN if i < game.stamina else Color("#304866"), CYAN)
    text("%d틱  ·  %.1f초" % [game.ticks, game.ticks * 0.2], 50, 248, 30, Color("#bdcfdf"))
    text("안전 지붕에서는 멈춰 기력을 채우세요", 480, h * 0.67, 31, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 870)
    for k in 3:
        var action: String = ["left", "right", "sprint"][k]
        button(Rect2(35 + k * 310, h - 190, 270, 155), ["←  왼쪽", "오른쪽  →", "질주"][k], held.values().has(action), 34)
    if game.mode == "RESTART":
        draw_rect(Rect2(0, 0, 960, h), Color("#081225", 0.91))
        text("잠시 숨 고르기", 480, h * 0.37, 61, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 870)
        text("현재 지붕부터 다시 / 처음부터", 480, h * 0.48, 31, CYAN, HORIZONTAL_ALIGNMENT_CENTER, 870)
        button(Rect2(175, h * 0.60, 610, 85), "현재 지붕 재시작")
        button(Rect2(175, h * 0.60 + 105, 610, 85), "처음부터 새로 시작")
        button(Rect2(175, h * 0.60 + 210, 610, 70), "계속하기", false, 30)

func _title(h: float) -> void:
    text("ROOFTOP  /  01", 480, h * 0.19, 31, CYAN, HORIZONTAL_ALIGNMENT_CENTER, 880)
    text("숨 고르는", 480, h * 0.32, 94, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 900)
    text("지붕길", 480, h * 0.42, 112, ORANGE, HORIZONTAL_ALIGNMENT_CENTER, 900)
    draw_line(Vector2(170, h * 0.49), Vector2(790, h * 0.49), CYAN, 4)
    text("달려서 건너고, 멈춰서 숨 쉬세요.", 480, h * 0.56, 38, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 900)
    text("3개의 지붕  ·  3개의 목숨", 480, h * 0.63, 27, CYAN, HORIZONTAL_ALIGNMENT_CENTER, 900)
    button(Rect2(165, h * 0.72, 630, 110), "게임 시작   →", true, 43)
    text("최고 기록  %s" % ("없음" if game.best < 0 else "%d틱" % game.best), 480, h * 0.72 + 161, 25, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 900)

func _tutorial(h: float) -> void:
    text("길을 읽는 법", 480, h * 0.16, 66, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 900)
    var top := h * 0.23
    panel(Rect2(90, top, 780, 100), Color("#1d3555"))
    text("01   ← → / A D 로 한 칸씩 이동", 115, top + 62, 33)
    panel(Rect2(90, top + 120, 780, 100), Color("#1d3555"), ORANGE)
    text("02   빗금 지붕은 Shift / 질주를 누르고 진입", 115, top + 182, 30)
    panel(Rect2(90, top + 240, 780, 100), Color("#1d3555"))
    text("03   안전한 칸에서 손을 떼면 기력 +1", 115, top + 302, 32)
    text("기력 4칸 · 약한 지붕 진입마다 1칸 소비", 480, top + 416, 29, CYAN, HORIZONTAL_ALIGNMENT_CENTER, 900)
    text("화면 아래 세 버튼을 동시에 누를 수 있어요", 480, top + 468, 27, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 900)
    button(Rect2(165, h * 0.72, 630, 110), "알겠어요   →", true, 40)

func _end_screen(h: float, won: bool) -> void:
    text("완주!" if won else "다시 숨을 고르세요", 480, h * 0.33, 75 if won else 62, CYAN if won else ORANGE, HORIZONTAL_ALIGNMENT_CENTER, 920)
    text("세 지붕을 모두 건넜어요" if won else "목숨을 모두 사용했어요", 480, h * 0.44, 35, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 890)
    text("이번 기록 %d틱  ·  최고 %s" % [game.ticks, "없음" if game.best < 0 else "%d틱" % game.best], 480, h * 0.55, 31, CREAM, HORIZONTAL_ALIGNMENT_CENTER, 900)
    button(Rect2(165, h * 0.72, 630, 110), "다시 달리기", true, 42)
