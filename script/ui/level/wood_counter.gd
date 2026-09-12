extends Control


func _ready() -> void:
	# 监听 GameManager 的分数改变信号
	UiUpdate.wood_updated.connect(_on_wood_updated)


func _on_wood_updated(new_score: int,target_score:int) -> void:
	$CollectedNum.text = str(new_score) + " / " + str(target_score)
