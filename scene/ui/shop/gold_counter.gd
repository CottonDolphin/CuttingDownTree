extends HBoxContainer


func _ready() -> void:
	# 监听 GameManager 的分数改变信号
	UiUpdate.gold_updated.connect(_on_gold_updated)


func _on_gold_updated(amount:int) -> void:
	$CollectedNum.text = str(amount)
