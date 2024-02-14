@tool
extends EditorPlugin

const AUTOLOAD_NAME = "IDP"

func _enter_tree():
	# Initialization of the plugin goes here.
#	add_custom_type("KnowledgeBase","Node",preload("res://addons/IDP/kb.gd"),preload("res://icon.svg"))
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/IDP/idp.gd")


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_autoload_singleton(AUTOLOAD_NAME)
#	remove_custom_type("KnowledgeBase")
	
