# 地图板块
class_name Ground
extends MeshInstance3D

# 配置数据
static var x:int
static var y:int
static var z:int

# 应用配置
static func apply_config(config:Dictionary) -> void:
		
		x = int(config.get("x","10"))
		y = int(config.get("y","10"))
		z = int(config.get("z","10"))
		pass
		
func _ready() -> void:
	# 1. 设置网格大小
	self.mesh.size = Vector3(x, y, z)
	
	## 2. 同步碰撞体大小
	var collision = $StaticBody3D/CollisionShape3D
	if collision and collision.shape is BoxShape3D:
		collision.shape.size = Vector3(x, y, z)
