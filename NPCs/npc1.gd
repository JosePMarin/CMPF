extends KinematicBody2D

var SPEED = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	var bodies = get_node("body").get_overlapping_bodies()
	if(bodies.size() !=0):
		for body in bodies:
			if (body.is_in_group("player")):
				if (body.get_bone_global_pose().x<self.get_blobal_pos().x):
					pass

	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
