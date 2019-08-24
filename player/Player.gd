#Librerias
extends KinematicBody2D


#Variables constantes
const SPEED = 120
const HIDE_SPEED = 40
var DEATH=false
var HEALTH = 100

#Objetos
var movedir = Vector2()
var spritedir = Vector2()
	
#funcion que checkea el estado del personaje para mostrar animaciones
func _ready():
	pass
	#TODO: state_machine = $AnimationTree.get(paremeters_player) TEST

#funcion que controla el movimiento y las animaciones
func _physics_process(delta):
	_healthstate_loop()
	_controls_loop()
	_movement_loop()
	_spritedir_loop()
	_animloader_loop()
	#TODO: _spritestate_loop()

#funcion que cambia la animacion en funcion del entorno
func _animloader_loop():
	if movedir != Vector2.ZERO:
	 	if is_on_wall():
	 		if test_move(transform, spritedir):
	    		anim_switch("Push")
	 	else: 
	 		anim_switch("Run")
	else:
		anim_switch("Idle")

#funcion que altera el movimiento en funcion de los inputs de teclado: proyecto/ajustes/mapa_de_entrada
func _controls_loop():
	movement()

#funcion que aplica el movimiento introducido (por _controls_loop()) y normalizado a la constante SPEED
func _movement_loop():
	var linear_velocity
	var floor_normal = Vector2(0,0)
	if input.hide():
		linear_velocity = movedir.normalized() * HIDE_SPEED
	else:
		linear_velocity = movedir.normalized() * SPEED
	move_and_slide(linear_velocity, floor_normal)

#funcion que checkea si movedir se mueve y no es infinito para actualizar la posicion del spirte
func _spritedir_loop():
	if movedir != Vector2.ZERO && movedir != Vector2.INF:
		spritedir = movedir

func _healthstate_loop():
	if HEALTH<=0:
		DEATH=true
	


################## MEMBER FUNCTIONS ##########################

#funcion que devuelve la direccion en string
func action_to_String(direction:Vector2) -> String:
	if direction.x == -1:
		return "Left"
	if direction.x == 1:
		return "Right"
	if direction.y == -1:
		return "Up"
	if direction.y == 1:
		return "Down"
	if input.hide():
		return "Hide"
	if die():
		return "Die" #TODO: create "Die" animation
	return "Down" #TODO: create "Idle" animation  

#funcion que actualiza la animacion en funcion de la direccion
func anim_switch(anim):
	var newanim = str(anim,action_to_String(spritedir))
	if $Anim.current_animation != newanim:
		$Anim.play(newanim)
		

#funcion que devuelve el input de teclado
class input:
	static func left():
		return int(Input.is_action_pressed("ui_left"))
	static func right():
		return int(Input.is_action_pressed("ui_right"))
	static func up():
		return int(Input.is_action_pressed("ui_up"))
	static func down():
		return int(Input.is_action_pressed("ui_down"))
	static func attack1():
		return Input.is_action_pressed("ui_attack1")
	static func hide():
		return Input.is_action_pressed("ui_hide")

#funcion que describe el movimiento
func movement():
	movedir.x = -input.left() + input.right()
	movedir.y = -input.up() + input.down()

func hurt():
	#TODO: boolean that returns true if damage
	pass
	
func die():
	if DEATH:
		set_physics_process(false)
		return true
	return false

func _on_SwordHit_area_entered(area):
	if area.is_in_group("hurtbox"):
		pass#area.take_damage()
	return true