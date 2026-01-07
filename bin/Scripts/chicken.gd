extends CharacterBody2D

# 🧠 STATE (FSM)
enum State {
	WALK,
	EAT
}

var state: State = State.WALK

# ⚙️ CẤU HÌNH
var speed: float = 5.0
var direction: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $StateTimer

# 🚀 KHỞI TẠO
func _ready() -> void:
	randomize()
	start_walk()

# 🎮 VÒNG LẶP VẬT LÝ
func _physics_process(delta: float) -> void:
	match state:
		State.WALK:
			velocity = direction * speed
			sprite.play("walking")

			# ➡️⬅️ LẬT SPRITE KHI ĐI NGANG
			if direction.x != 0:
				sprite.flip_h = direction.x < 0

		State.EAT:
			velocity = Vector2.ZERO
			sprite.play("eating")

	move_and_slide()

# 🚶 BẮT ĐẦU ĐI (RANDOM)
func start_walk() -> void:
	state = State.WALK

	# 🎲 RANDOM TRỤC DI CHUYỂN
	if randf() < 0.5:
		# ➡️⬅️ NGANG
		direction = Vector2(randi_range(-1, 1), 0)
		if direction.x == 0:
			direction.x = 1
	else:
		# ⬆️⬇️ DỌC
		direction = Vector2(0, randi_range(-1, 1))
		if direction.y == 0:
			direction.y = 1

	# ⏱️ THỜI GIAN ĐI RANDOM
	$state_timer.wait_time = randf_range(1.5, 4.0)
	$state_timer.start()

# 🌽 BẮT ĐẦU ĂN
func start_eat() -> void:
	state = State.EAT

	# ⏱️ THỜI GIAN ĂN RANDOM
	$state_timer.wait_time = randf_range(1.0, 3.0)
	$state_timer.start()

# ⏲️ TIMER CHUYỂN STATE
func _on_state_timer_timeout() -> void:
	if state == State.WALK:
		start_eat()
	else:
		start_walk()
