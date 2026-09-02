# 游戏关卡
extends Node

#当前轮次
var round:int = 1

#初始游戏目标
@export var init_target:int = 10

#每轮增加的目标
@export var plus_target:int = 10 

#当前轮次目标
var round_target:int

#玩家
@export var player:Player


func _ready() -> void:
	# 计算当前轮次目标
	round_target = init_target + plus_target * (round - 1)
	GameManager.update_target_amount(round_target)
	
	

func _process(delta: float) -> void:
	pass
