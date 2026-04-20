extends Node

@export var possible_weapons: Array[WeaponData]
@export var black_hole_scene: PackedScene
@export var weapon_pickup_scene: PackedScene

var low_gravity_on: bool = false
var big_recoil_on: bool = false
var tiny_mode_on: bool = false
var giant_mode_on: bool = false
var one_hit_mode_on: bool = false
var super_speed_on: bool = false
var chaos_mode_on: bool = false

var key_1_down: bool = false
var key_2_down: bool = false
var key_3_down: bool = false
var key_4_down: bool = false
var key_5_down: bool = false
var key_6_down: bool = false
var key_7_down: bool = false
var key_8_down: bool = false
var key_9_down: bool = false
var key_0_down: bool = false

func _process(_delta: float) -> void:
	check_key(KEY_1, key_1_down, "_cheat_1")
	check_key(KEY_2, key_2_down, "_cheat_2")
	check_key(KEY_3, key_3_down, "_cheat_3")
	check_key(KEY_4, key_4_down, "_cheat_4")
	check_key(KEY_5, key_5_down, "_cheat_5")
	check_key(KEY_6, key_6_down, "_cheat_6")
	check_key(KEY_7, key_7_down, "_cheat_7")
	check_key(KEY_8, key_8_down, "_cheat_8")
	check_key(KEY_9, key_9_down, "_cheat_9")
	check_key(KEY_0, key_0_down, "_cheat_0")

	key_1_down = Input.is_key_pressed(KEY_1)
	key_2_down = Input.is_key_pressed(KEY_2)
	key_3_down = Input.is_key_pressed(KEY_3)
	key_4_down = Input.is_key_pressed(KEY_4)
	key_5_down = Input.is_key_pressed(KEY_5)
	key_6_down = Input.is_key_pressed(KEY_6)
	key_7_down = Input.is_key_pressed(KEY_7)
	key_8_down = Input.is_key_pressed(KEY_8)
	key_9_down = Input.is_key_pressed(KEY_9)
	key_0_down = Input.is_key_pressed(KEY_0)

func check_key(key_code: Key, was_down: bool, method_name: String) -> void:
	var is_down: bool = Input.is_key_pressed(key_code)
	if is_down and not was_down:
		call(method_name)

func get_game_manager() -> Node:
	return get_tree().get_root().find_child("GameManager", true, false)

func get_player1() -> Node:
	return get_tree().get_root().find_child("Player1", true, false)

func get_player2() -> Node:
	return get_tree().get_root().find_child("Player2", true, false)

func get_players() -> Array[Node]:
	var players: Array[Node] = []
	var p1: Node = get_player1()
	var p2: Node = get_player2()

	if p1 != null:
		players.append(p1)
	if p2 != null:
		players.append(p2)

	return players

func _cheat_1() -> void:
	toggle_low_gravity()

func _cheat_2() -> void:
	toggle_big_recoil()

func _cheat_3() -> void:
	toggle_tiny_mode()

func _cheat_4() -> void:
	toggle_giant_mode()

func _cheat_5() -> void:
	weapon_rain()

func _cheat_6() -> void:
	spawn_black_hole()

func _cheat_7() -> void:
	toggle_one_hit_mode()

func _cheat_8() -> void:
	toggle_super_speed()

func _cheat_9() -> void:
	give_random_weapons_both()

func _cheat_0() -> void:
	toggle_chaos_mode()

func toggle_low_gravity() -> void:
	low_gravity_on = not low_gravity_on

	for player: Node in get_players():
		if low_gravity_on:
			player.gravity = 400.0
		else:
			player.gravity = 1200.0

	print("Cheat 1: low gravity = ", low_gravity_on)

func toggle_big_recoil() -> void:
	big_recoil_on = not big_recoil_on

	for player: Node in get_players():
		if player.current_weapon != null:
			if big_recoil_on:
				player.current_weapon.recoil *= 3.0
			else:
				player.current_weapon.recoil /= 3.0

	print("Cheat 2: big recoil = ", big_recoil_on)

func toggle_tiny_mode() -> void:
	tiny_mode_on = not tiny_mode_on

	for player: Node in get_players():
		player.scale = Vector2(0.6, 0.6) if tiny_mode_on else Vector2(1, 1)

	print("Cheat 3: tiny mode = ", tiny_mode_on)

func toggle_giant_mode() -> void:
	giant_mode_on = not giant_mode_on

	for player: Node in get_players():
		player.scale = Vector2(1.6, 1.6) if giant_mode_on else Vector2(1, 1)

	print("Cheat 4: giant mode = ", giant_mode_on)

func weapon_rain() -> void:
	var gm: Node = get_game_manager()
	if gm == null:
		print("No GameManager found")
		return
	if weapon_pickup_scene == null:
		print("No weapon_pickup_scene assigned")
		return
	if possible_weapons.is_empty():
		print("No possible_weapons assigned")
		return
	if gm.current_room == null:
		print("No current room")
		return

	var item_spawns: Node = gm.current_room.get_node_or_null("ItemSpawns")
	if item_spawns == null:
		print("No ItemSpawns in room")
		return

	for child: Node in item_spawns.get_children():
		var pickup: Node = weapon_pickup_scene.instantiate()
		var random_weapon: WeaponData = possible_weapons[randi() % possible_weapons.size()]
		pickup.weapon_data = random_weapon

		var spawn_pos: Vector2 = child.global_position + Vector2(randf_range(-50.0, 50.0), -350.0)
		get_tree().current_scene.call_deferred("add_child", pickup)
		pickup.set_deferred("global_position", spawn_pos)

	print("Cheat 5: weapon rain")

func spawn_black_hole() -> void:
	if black_hole_scene == null:
		print("No black_hole_scene assigned")
		return

	var black_hole = black_hole_scene.instantiate()
	var center: Vector2 = get_viewport().get_visible_rect().size * 0.5

	get_tree().current_scene.call_deferred("add_child", black_hole)
	black_hole.set_deferred("global_position", center)

	print("Cheat 6: black hole")

func toggle_one_hit_mode() -> void:
	one_hit_mode_on = not one_hit_mode_on

	for player: Node in get_players():
		if one_hit_mode_on:
			player.max_health = 1
			player.health = 1
		else:
			player.max_health = 100
			player.health = 100

	print("Cheat 7: one-hit mode = ", one_hit_mode_on)

func toggle_super_speed() -> void:
	super_speed_on = not super_speed_on

	for player: Node in get_players():
		if super_speed_on:
			player.move_speed = 650.0
			player.jump_force = -700.0
		else:
			player.move_speed = 320.0
			player.jump_force = -500.0

	print("Cheat 8: super speed = ", super_speed_on)

func give_random_weapons_both() -> void:
	var p1: Node = get_player1()
	var p2: Node = get_player2()

	give_random_weapon(p1)
	give_random_weapon(p2)

	print("Cheat 9: both got random weapons")

func toggle_chaos_mode() -> void:
	chaos_mode_on = not chaos_mode_on

	if chaos_mode_on:
		low_gravity_on = false
		super_speed_on = false
		one_hit_mode_on = false

		toggle_low_gravity()
		toggle_super_speed()
		toggle_one_hit_mode()
		give_random_weapons_both()
		weapon_rain()
	else:
		if low_gravity_on:
			toggle_low_gravity()
		if super_speed_on:
			toggle_super_speed()
		if one_hit_mode_on:
			toggle_one_hit_mode()

	print("Cheat 0: chaos mode = ", chaos_mode_on)

func give_random_weapon(player: Node) -> void:
	if player == null:
		return
	if possible_weapons.is_empty():
		return
	if not player.has_method("pickup_weapon"):
		return

	var random_weapon: WeaponData = possible_weapons[randi() % possible_weapons.size()]
	player.current_weapon = null
	player.clear_held_weapon_visual()
	player.pickup_weapon(random_weapon)
