# 游戏关卡
extends Node

#当前轮次
var round:int = 1

#玩家
@export var player:Player

#关卡计时器
@onready var timer:Timer = $Timer

#初始游戏目标
@export_group("关卡目标设置")
@export var init_target:int = 50
#每轮增加的目标
@export var plus_target:int = 10 
@export var plus_target_rate:float = 0.5 


#当前轮次目标
var round_target:int

#初始时间设置
@export_group("关卡时间设置")
@export var init_time:float = 60
@export var plus_time_rate:float = 0.1

#当前轮次时间
var round_time:float


# 开始当前轮次的游戏
func start_game() -> void:
	#更新关卡数据
	update_level_data()
	# 计算当前轮次目标
	GameManager.update_target_amount(round_target)
	#开始计时
	start_game_timer(round_time)

# 更新关卡数据
func update_level_data() -> void:
	#round_target = init_target + plus_target * (round - 1)
	round_target = init_target + init_target * plus_target_rate * (round - 1)
	round_time = init_time + plus_time_rate * init_time * (round - 1)

# 启动计时器的函数
func start_game_timer(seconds: float) -> void:
	timer.wait_time = seconds
	timer.one_shot = true # 设为 true 只倒计时一次
	timer.start() # 开始计时

# 结算本轮游戏结果
func check_result() -> void:
	var collected_num = GameManager.get_item_num("wood")
	#当收集的木头大于等于目标数时，进入下一轮，否则失败，从头开始
	if collected_num >= round_target:
		success()
	else:
		pass
		#fail()

# 游戏成功触发的逻辑
func success() -> void:
	print("关卡通过！进入下一轮")
	# 1. 轮次 +1
	round += 1
	
	# 2. 清空本轮已交的木头数据
	GameManager.reset_wood_data() 
	
	
	# 3. 重新计算并启动下一轮
	start_game()

# 游戏失败触发的逻辑
func fail() -> void:
	restart_game()

# 彻底重新开始（返回第一轮或重载关卡）
func restart_game() -> void:
	# 1. 重置全局 GameManager 数据
	GameManager.reset_all_data()
	
	# 2. 直接重新加载当前关卡场景
	get_tree().reload_current_scene()

func _on_level_timer_timeout() -> void:
	print("计时结束，触发特定逻辑！")
	# 触发游戏结束、结算或生成敌人等逻辑
	check_result()

func _ready() -> void:
	start_game()

func _process(delta: float) -> void:
	if not timer.is_stopped():
		var time_left = int(timer.time_left)
		# 更新 UI，例如：
		UiUpdate.update_time(time_left)
