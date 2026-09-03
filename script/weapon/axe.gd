extends Node3D


# 定义武器被阻挡和解除阻挡的信号
signal weapon_blocked_changed(is_blocked: bool, block_normal: Vector3)

@onready var block_detector: Area3D = $BlockDetector

@export var attack_power:float = 10




func _ready():
	pass
	



func _on_block_detector_body_entered(body: Node3D) -> void:
	# 过滤掉玩家自己，只检测静态物体（如树木 Layer 3）
	print("检测到树木")
	if body is StaticBody3D:
		weapon_blocked_changed.emit(true, global_transform.basis.z) # 传递阻挡状态


func _on_block_detector_body_exited(body: Node3D) -> void:
	if body is StaticBody3D:
		weapon_blocked_changed.emit(false, Vector3.ZERO)
