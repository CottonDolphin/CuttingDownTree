extends Control


func _ready() -> void:
	# 监听 GameManager 的分数改变信号
	UiUpdate.time_updated.connect(_on_time_updated)


func _on_time_updated(time_left:int) -> void:
	$TimeLabel.text = str(time_left)
