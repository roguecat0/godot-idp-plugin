class_name Vocabulary
extends KnowledgeBaseBlock

var types: Array
var functions: Array
const practice_str : String = """
vocabulary V {
	type T
	type T := {c1, c2, c3}
	
	type T := {1,2,3}
	type T := {1..3}
	// built-in types: 𝔹, ℤ, ℝ, Date, Concept Bool, Int, Real, Date, Concept

	p: () -> Bool
	p1, p2: T1*T2 -> Bool
	f: T -> T
	f1, f2: Concept[T1->T2] -> T

	[this is the intended meaning of p]
	p : () → Bool

	var x in T
	import W
}"""
# Called when the node enters the scene tree for the first time.
func _ready():
	block_name = "V" # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func parse_from_string(str_voc: String) -> void:
	pass
