class_name Wood
extends GameResource

var data:Dictionary


func _ready() -> void:
	pass 



func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	# 当玩家进入范围时
	print("木材被碰到了")
	if body is Player:
		body.add_to_backpack(data,1)
		queue_free()
