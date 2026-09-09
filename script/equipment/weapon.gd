class_name Weapon 
extends Node

@export var attack_power:float = 10

@onready var anim_player:AnimationPlayer = $AnimationPlayer

# 攻击
func attack() -> void:
	
	# 通过变量 holding_weapon 获取它下面的 AnimationPlayer
	
	if anim_player:
		if not anim_player.is_playing():
			anim_player.play("attack")
			
	else:
		push_warning("holding_weapon 下找不到 AnimationPlayer")
