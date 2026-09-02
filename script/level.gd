# 游戏关卡
extends Node

#本轮游戏目标
@export var level_targe:int = 10

#玩家
@export var player:Player


func _ready() -> void:
	var current_num:String = str(GameManager.get_item_num("wood"))
	var targe_num:String = str(level_targe)
	$HUB/WoodCounter/CollectedNum.text = current_num + " / " + targe_num

func _process(delta: float) -> void:
	pass
