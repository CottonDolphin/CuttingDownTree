# 出生点
class_name Forest
extends Block

# 配置数据
#板块布局
static var layout:Array[Vector2] = []  
#是否随机生成
static var is_random:bool

# 生成树木数量的随机范围
@export var trees_num_range:Vector2 = Vector2(5,10)

# 生成树木位置的范围
var generate_x_limit: Vector2
var generate_z_limit: Vector2

# 当前生成的树的坐标
var current_tree_pos:Array[Vector3] = []

# 生成树的场景
@export var tree_scene:PackedScene


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
		
		#id = int(config.get("id","0"))
		#self_define_name = config.get("name")
		set_layout(config)
		is_random = config.get("is_random",false)
		
		
		pass

# 生成树
func generate_trees() -> void:
	if not tree_scene:
		push_error("tree_scene 未赋值！")
		return
	
	#随机生成树木的数量
	var generate_num:int = randi_range(trees_num_range.x,trees_num_range.y)
	
	for i in generate_num:
		
		#获取树生成的位置
		var pos:Vector3 = get_generate_pos()
		
		# 将树场景实例化
		if pos:
			var tree = tree_scene.instantiate() as MyTree
			add_child(tree)
			tree.position = pos
			
			
#获取树生成的位置
func get_generate_pos() -> Vector3:
	var pos:Vector3
	
	var x:float = randf_range(generate_x_limit.x,generate_x_limit.y)
	var z:float = randf_range(generate_z_limit.x,generate_z_limit.y)
	var y:float = $Ground.y / 2
	var random_pos:Vector3 = Vector3(x,y,z)
	
	#检查是否给树生成的空间
	if check_have_space(random_pos):
		pos = Vector3(x,y,z)
		current_tree_pos.append(pos)
		
	return pos

#检查是否给树生成的空间
func check_have_space(pos:Vector3) -> bool:
	var result:bool = true
	
	var tree_x:float = 2
	var tree_z:float = 2
	var max_distance:float = sqrt(pow(tree_x/2,2) + pow(tree_z/2,2)) * 2
	
	for p in current_tree_pos:
		var distance:float = (pos - p).length()
		if distance <= max_distance:
			result = false
			break
	
	return result

func _ready() -> void:
	# 在这里计算，确保 $Ground 已准备好
	var half_x: float = $Ground.x / 2.0 - 1.0
	var half_z: float = $Ground.z / 2.0 - 1.0
	
	generate_x_limit = Vector2(-half_x, half_x)
	generate_z_limit = Vector2(-half_z, half_z)
	
	generate_trees()
