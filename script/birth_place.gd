# 出生点
class_name BirthPlace
extends Block

# 配置数据
#板块布局
static var layout:Array[Vector2] = []  
#是否随机生成
static var is_random:bool


#设置板块布局
static func set_layout(config:Dictionary) -> void:
	var layout_str:String = config["layout"]
	var vector_str_arr:Array[String] = []
	if layout_str:
		vector_str_arr.append_array(layout_str.split(" "))
	for vec_str in vector_str_arr:
		var vec:Vector2 = str_to_var("Vector2" + vec_str)	
		layout.append(vec)



# 应用配置
static func apply_config(config:Dictionary) -> void:
		
		set_layout(config)
		is_random = config.get("is_random",false)
		
		
		pass
