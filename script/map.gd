# 地图
class_name Map
extends Node3D


#可使用的板块名
static var all_block_name:Array[String] = []

# 地图的行数和列数
static var rows_num:int = 0
static var cols_num:int = 0

# 出生点的行数和列数
var birth_place_row = 0
var birth_place_col = 0


#用来检测哪些地方可以放置板块
var blocks:Array[bool]

# 应用配置
static func apply_config(config:Dictionary) -> void:
	
	#设置地图的行数和列数
	rows_num = config.get("row",0)
	cols_num = config.get("col",0)
	
	#获取所有的板块名
	get_all_block_name()
	
	
	pass

#获取所有的随机生成板块名
static func get_all_block_name() -> void:
	var all_block_config:Dictionary = Config._get_config_by_type("Block")
	for id in all_block_config:
		var config:Dictionary = all_block_config.get(id)
		# 排除固定生成的板块
		if config.get("is_random"):
			all_block_name.append(config.get("name"))
	all_block_name.assign(all_block_name.map(func(s: String): return s.to_snake_case()))
	
#设置出生点的位置
func set_birth_place_pos() -> void:
	birth_place_row = rows_num
	birth_place_col = cols_num / 2
	$BirthPlace.position.x = 0
	$BirthPlace.position.y = 0
	$BirthPlace.position.z = 0
	
	# 标记出生点的位置
	var index:int = (birth_place_row - 1) * cols_num + (birth_place_col - 1)
	blocks[index] = true
	

# 初始化板块信息
func init_blocks() -> void:
	for r in range(rows_num):
		for c in range(cols_num):
			blocks.append(false)
	
# 使用随机板块填充地图
func fill_map() -> void:
	for r in range(rows_num):
		for c in range(cols_num):
			var index:int = r * cols_num + c
			if not blocks[index]:
				generate_random_block(r,c)
	
# 生成随机板块填充对应区域
func generate_random_block(r: int, c: int):
	var useable_block_name: Array[String] = all_block_name.duplicate()
	
	var random_block_name: String
	var block_scene: PackedScene  # 修改类型为 PackedScene (场景)
	var block_script: GDScript    # 用于提取 layout 静态数据
	
	while true:
		random_block_name = useable_block_name.pick_random()
		
		# 1. 加载 .tscn 场景文件
		block_scene = get_block_scene(random_block_name)
		
		if block_scene:
			block_script = load("res://script/" + random_block_name + ".gd") as GDScript

			# 判断当前板块是否可以放入地图
			if block_script and check_block_is_fit(block_script, r, c):
				break

		useable_block_name.erase(random_block_name)
		if useable_block_name.is_empty():
			break
	
	if block_scene and block_script:
		generate_block(block_script,block_scene,r, c)

# 加载板块场景文件
func get_block_scene(block_name) -> PackedScene:
	var scene_path: String = "res://scene/" + block_name + ".tscn" # 注意你的场景存放目录
	var block_scene: PackedScene = load(scene_path) as PackedScene
	return block_scene
	
# 加载板块脚本文件
func get_block_script(block_name) -> GDScript:
	var block_script: GDScript = load("res://script/" + block_name + ".gd") as GDScript
	return block_script
	
# 生成板块
func generate_block(block_script:GDScript,block_scene: PackedScene,r: int, c: int):
	# 标记板块位置信息
		mark_blcok_pos(block_script, r, c)
		
		# 【关键修改】使用 instantiate() 实例化完整场景（包含所有子节点）
		var block: Block = block_scene.instantiate() as Block
		
		# 设置板块位置
		set_block_pos(block, r, c)
		
		# 将板块添加到节点树
		add_child(block)


# 检查当前板块是否可以放入地图
func check_block_is_fit(block_class:GDScript,row:int,col:int):
	var result:bool = true
	#检查的坐标
	var c_r:int = 0
	var c_c:int = 0
	var index:int = 0
	for pos in block_class.layout:
		# 计算板块所占位置
		c_r = row + pos.x
		c_c = col + pos.y
		# 【新增】必须先检查坐标是否超出了地图边界！
		if c_r < 0 or c_r >= rows_num or c_c < 0 or c_c >= cols_num:
			return false
		
		index = c_r * cols_num + c_c
		if blocks[index]:
			result = false
			break
	return result

#标记板块位置信息
func mark_blcok_pos(block_class:GDScript,row:int,col:int) -> void:
	#检查的坐标
	var c_r:int = 0
	var c_c:int = 0
	var index:int = 0
	for pos in block_class.layout:
		# 计算板块所占位置
		c_r = row + pos.x
		c_c = col + pos.y
		index = c_r * cols_num + c_c
		blocks[index] = true

#设置板块的位置
func set_block_pos(block:Block,row:int,col:int) -> void:
	# 参照出生点计算相对位置
	var current_row:int = row + 1
	var current_col:int = col + 1
	
	var ground: MeshInstance3D = block.get_node("Ground") 
	block.position.z = (current_row - birth_place_row) * ground.mesh.size.z
	block.position.x = (current_col - birth_place_col) * ground.mesh.size.x
	block.position.y = $BirthPlace.position.y

func _ready() -> void:
	
	#根据地图的长和宽将blocks填充对应数量的false,表示当前没有板块
	init_blocks()
	
	#设置出生点的位置
	set_birth_place_pos()
	
	#根据地图大小用随机板块填充整个地图
	fill_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
