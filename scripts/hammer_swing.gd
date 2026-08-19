extends Node2D

# 망치를 휘두를 때 잠깐 나타났다 사라지는 부채꼴 슬래시 이펙트.
# Player.gd에서 코드로 인스턴스를 생성해서 붙여줍니다 (별도 씬 파일 없이 동작).

@export var lifetime : float = 0.28       # 이펙트가 살아있는 총 시간(초)
@export var radius : float = 34.0         # 슬래시 반지름
@export var arc_deg : float = 120.0       # 슬래시가 그리는 부채꼴 각도(도)
@export var swing_color : Color = Color(1.0, 0.95, 0.8, 1.0)
@export var core_color : Color = Color(1.0, 1.0, 1.0, 1.0)   # 칼끝이 지나가는 밝은 코어 라인 색

var elapsed : float = 0.0

func _ready() -> void:
	z_index = 5
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var t = elapsed / lifetime

	# 앞부분(35%)에서는 망치가 휘둘러지며 부채꼴이 채워지고,
	# 뒷부분(65%)에서는 서서히 투명해지며 사라집니다.
	var sweep_t = clamp(t / 0.35, 0.0, 1.0)
	var fade_t = clamp((t - 0.35) / 0.65, 0.0, 1.0)
	var alpha = 1.0 - fade_t

	var half_arc = deg_to_rad(arc_deg) * 0.5
	var start_rad = -half_arc
	var end_rad = lerp(-half_arc, half_arc, sweep_t)

	if end_rad - start_rad < 0.01:
		return

	var points = PackedVector2Array()
	points.append(Vector2.ZERO)
	var steps = 20
	for i in range(steps + 1):
		var a = lerp(start_rad, end_rad, float(i) / steps)
		points.append(Vector2(cos(a), sin(a)) * radius)

	# 채워진 부채꼴(은은한 글로우)
	draw_colored_polygon(points, Color(swing_color.r, swing_color.g, swing_color.b, alpha * 0.35))

	# 바깥 테두리(궤적선) - 두껍고 은은하게, 글로우처럼
	var outline = points.slice(1)
	draw_polyline(outline, Color(swing_color.r, swing_color.g, swing_color.b, alpha * 0.55), 7.0, true)

	# 밝은 코어 라인 - 망치 끝이 실제로 지나간 자리를 얇고 선명하게
	draw_polyline(outline, Color(core_color.r, core_color.g, core_color.b, alpha), 2.0, true)

	# 초반 임팩트 프레임: 휘두르기 시작하는 순간 중심에서 퍼지는 섬광
	if t < 0.15:
		var flash_alpha = 1.0 - (t / 0.15)
		var flash_radius = radius * 0.3 * (1.0 + t * 3.0)
		draw_circle(Vector2.ZERO, flash_radius, Color(core_color.r, core_color.g, core_color.b, flash_alpha * 0.55))
