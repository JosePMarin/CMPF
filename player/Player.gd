#Librerias
extends KinematicBody2D


#Variables constantes
const SPEED = 120
const HIDE_SPEED = 40
var DEATH=false
var HEALTH=100
var STAMINA = 100
var TIME = 0
var HEALTH_REGEN=2
var STAMINA_REGEN=2
var damage=0

#Objetos
var movedir = Vector2()
var spritedir = Vector2()
var hurt_ref=hurt(damage)

	
#funcion que checkea el estado del personaje para mostrar animaciones
func _ready():
	pass
	#TODO: state_machine = $AnimationTree.get(paremeters_player)

#funcion que controla el movimiento y las animaciones
func _physics_process(delta):
	TIME+=delta
	_movement_loop()
	_controls_loop()
	_staminastate_loop()
	_healthstate_loop(hurt_ref)
	_spritedir_loop()
	_animloader_loop(delta)
	#TODO: _spritestate_loop()

#funcion que cambia la animacion en funcion del entorno
func _animloader_loop(delta):
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
	#TODO: attak()

#funcion que aplica el movimiento introducido (por _controls_loop()) y normalizado a la constante SPEED
func _movement_loop():
	var linear_velocity
	var floor_normal = Vector2(0,0)
	if is_on_wall():
		hurt(50)
	if input.hide():
		hurt(20)
		linear_velocity = movedir.normalized() * HIDE_SPEED
	else:
		linear_velocity = movedir.normalized() * SPEED
	move_and_slide(linear_velocity, floor_normal)

#funcion que checkea si movedir se mueve y no es infinito para actualizar la posicion del spirte
func _spritedir_loop():
	if movedir != Vector2.ZERO && movedir != Vector2.INF:
		spritedir = movedir

#funcion que devueve el estado de stamina en funcion de delta(frames)
func _staminastate_loop():
	if STAMINA<100:
		print ("regenerating stamina")
		STAMINA+=STAMINA_REGEN
	#print ("stamina= ", STAMINA)
	return STAMINA

#funcion que devuelve el estado de health en funcion de delta(frames)
func _healthstate_loop(hurt_ref):

	if HEALTH<=0:
		print ("death")
		DEATH=true
		return false
	else:
		if HEALTH<100:
			print ("regenerating health")
			HEALTH+=HEALTH_REGEN
			return HEALTH
		print ("damage: ",int(hurt_ref))
		if hurt_ref:
			HEALTH-=int(hurt_ref)
			print ("health after damage= ", HEALTH)
			return HEALTH
		print ("current health= ", HEALTH)
	
	


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

func hurt(damage):
	var damage_dealt
	if damage!=0:
		damage_dealt=damage
		damage=0
		return damage_dealt
	else:
		return false

func stamina():
	return false
	
func die():
	if DEATH==true:
		set_physics_process(false)
		#todo: cargar animacion muerte
		return true
	return false

func _on_SwordHit_area_entered(area):
	if area.is_in_group("hurtbox"):
		pass#area.take_damage()
	return true