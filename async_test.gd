extends Node

signal done(idx, text)

func _ready() -> void:
	done.connect(sep_done)
	print("hello")
	var thread = Thread.new()
	done.emit(1,"hell on earth")
	thread.start(sep_ex.bind())
	print("main thread")

func sep_ex() -> void:
	print("executing...")
	call_deferred("emit_signal","done",3, "heaven on earth")
	print("should have ended")

func sep_done(idx, text) -> void:
	print("executing done: ", idx, "text: ", text)
