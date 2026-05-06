extends Control

# 인벤토리 슬롯 2개를 배열로 관리
# null = 빈 슬롯, 문자열 = 아이템 이름
var slots: Array = ["flashlight", null]

# 각 슬롯의 Panel 노드를 배열로 가져옴
@onready var slot_panels: Array = [
	$PanelContainer/HBoxContainer/Slot1,
	$PanelContainer/HBoxContainer/Slot2
]

func _ready():
	update_inventory_display()  # 시작 시 인벤토리 화면 업데이트

# 인벤토리 화면을 현재 slots 배열에 맞게 갱신
func update_inventory_display():
	# for i in range(2): i가 0, 1 순서로 반복 (슬롯이 2개이므로)
	for i in range(slots.size()):
		var panel = slot_panels[i]
		var item = slots[i]
		
		# 슬롯에 아이템이 있으면 강조 색, 없으면 기본 색
		if item != null:
			panel.modulate = Color(1, 1, 0.5)  # 노란빛 (아이템 있음)
		else:
			panel.modulate = Color(1, 1, 1)    # 흰색 (빈 슬롯)

# 외부에서 아이템을 추가할 때 호출하는 함수
func add_item(item_name: String) -> bool:
	# 빈 슬롯(null)을 찾아서 아이템을 넣음
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = item_name
			update_inventory_display()
			return true  # 추가 성공
	return false  # 빈 슬롯 없음 (인벤토리 꽉 참)
