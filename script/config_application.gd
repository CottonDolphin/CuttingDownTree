# 将配置加载到对应的类中
extends Node



func apply_all_config() -> void:
	
	var all_config = Config.get_data()
	for type in all_config:
		var config_of_one_type:Dictionary = all_config.get(type)
		for id in config_of_one_type:
			var config:Dictionary = config_of_one_type.get(id)
			if config.name == "Block":
				pass
			var all_classes:Array[Dictionary] = ProjectSettings.get_global_class_list().filter(func(c): return c.class == config.name)
			if all_classes:
				var target_class:GDScript = load(all_classes[0].path)
				# 2. 调用静态方法
				if target_class.has_method("apply_config"):
					target_class.apply_config(config)
	
		

			


# 获取所有需要配置的类名

func _ready() -> void:
	apply_all_config()
