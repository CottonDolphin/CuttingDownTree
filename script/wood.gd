class_name Wood
extends GameResource

@export var resource_type: String = "wood"


func _ready() -> void:
	pass 



func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	# 当玩家进入范围时
	print("木材被碰到了")
	if body is Player:
		body.backpack.add_stackable_item(resource_type,1)
		queue_free()
