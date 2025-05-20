extends Control

signal next_level_requested
signal retry_level_requested
signal home_requested

enum GameResult { VICTORY, DEFEAT }

@onready var result_title = $Panel/MarginContainer/VBoxContainer/ResultTitle
@onready var level_completed_label = $Panel/MarginContainer/VBoxContainer/RewardContainer/LevelCompletedLabel
@onready var coins_value = $Panel/MarginContainer/VBoxContainer/RewardContainer/CoinsEarnedContainer/CoinsValue
@onready var star_container = $Panel/MarginContainer/VBoxContainer/StarContainer
@onready var next_level_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/NextLevelButton
@onready var home_button = $Panel/MarginContainer/VBoxContainer/ButtonContainer/HomeButton
@onready var animation_timer = $AnimationTimer

@onready var coin_counter = get_node("/root/CoinCounter")

var animated_star_scene = preload("res://Scenes/ui/animated_star.tscn")
var stars = []

var current_stars = 0
var total_stars_possible = 3
var result_type = GameResult.VICTORY
var coins_earned = 0

var next_star_to_animate = 0

func _ready():
	coins_earned = coin_counter.get_level_coins()
	
	create_stars()
	
	next_level_button.pressed.connect(_on_next_level_button_pressed)
	home_button.pressed.connect(_on_home_button_pressed)
	animation_timer.timeout.connect(_animate_next_star)
	
	show_victory()
	setup_screen()
	
	animation_timer.start()


func create_stars():
	for child in star_container.get_children():
		child.queue_free()
	
	stars.clear()

	for i in range(3):
		var star = animated_star_scene.instantiate()
		star_container.add_child(star)
		stars.append(star.get_node("StarSprite"))
		star.get_node("StarSprite").set_inactive()

func setup_screen():
	coins_value.text = str(coins_earned)
	
	calculate_stars()
	
	if result_type == GameResult.VICTORY:
		result_title.text = "VICTORY!"
		level_completed_label.text = "Level Completed!"
		coin_counter.complete_level()

	else:
		result_title.text = "DEFEAT!"
		level_completed_label.text = "Try Again!"
		next_level_button.text = "Retry"

func calculate_stars():
	if coins_earned >= 25:
		current_stars = 3
	elif coins_earned >= 15:
		current_stars = 2
	elif coins_earned > 0:
		current_stars = 1
	else:
		current_stars = 0
	
	# Set to 2 for testing
	current_stars = 2

	next_star_to_animate = 0

func _animate_next_star():
	if next_star_to_animate < current_stars:
		stars[next_star_to_animate].appear()
		
		next_star_to_animate += 1
		
		animation_timer.start()
	else:
		pass

func show_victory():
	result_type = GameResult.VICTORY
	visible = true
	setup_screen()
	animation_timer.start()

func show_defeat():
	result_type = GameResult.DEFEAT
	visible = true
	setup_screen()
	animation_timer.start()

func _on_next_level_button_pressed():
	if result_type == GameResult.VICTORY:
		next_level_requested.emit()
	else :
		retry_level_requested.emit()

	queue_free()

func _on_home_button_pressed():
	home_requested.emit()
	get_tree().change_scene_to_file("res://Scenes/menu/menue.tscn")
	queue_free()
