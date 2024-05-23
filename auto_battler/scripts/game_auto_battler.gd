extends Node2D

var kb: KnowlegdeBase
var player_configs


func _ready() -> void:
	pass

func begin_battle():
	pass

func _on_rule_maker_player_config(kb_) -> void:
	kb = kb_
	$CanvasLayer.visible = false
	# print(kb.parse_to_idp())
	
