extends Resource
class_name ItemData

@export var id: int = -1 # ID để map với hệ thống cũ (0 = Carrot, 1 = Onion)
@export var name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D # Kéo ảnh vào đây
@export var max_stack_size: int = 99 # Tối đa 99 cái/ô
