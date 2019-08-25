#Librerias
extends KinematicBody2D


#Variables constantes
const SPEED = 120
const HIDE_SPEED = 40
var DEATH=false
var HEALTH=100
var STAMINA = 100
var TIME = 0
var HEALTH_REGEN=1
var STAMINA_REGEN=1
var damage=0
var counter=0
var TIME_AUX=0
var hurted=false
var hurtedTIME=0
var fps= 60
var inicioSegundo=false

#Objetos
var movedir = Vector2()
var spritedir = Vector2()
var damage_dealt=0

	
#funcion que checkea el estado del personaje para mostrar animaciones
func _ready():
	pass
	#TODO: state_machine = $AnimationTree.get(paremeters_player)

#funcion que controla el movimiento y las animaciones
func _physics_process(delta):
	TIME+=delta
	_print_tiempo(TIME,TIME_AUX,delta)
	_movement_loop()
	_controls_loop()
	_staminaRegen_loop()
	_healthstate_loop(damage_dealt)
	_spritedir_loop()
	_animloader_loop(delta)
	_healthRegen_loop()
	_hurted_delay()
	#print ("TIME_AUX: ",int(TIME_AUX))
	counter+=1
	inicioSegundo=false

	#TODO: _spritestate_loop()
	
func _print_tiempo(TIME,TIME_AUX,delta):
	if counter == fps:
		print ("TIEMPO: ",int(TIME))
		print ("health: ",HEALTH)
		counter=0
		inicioSegundo=true

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
	if DEATH==false:
		var linear_velocity
		var floor_normal = Vector2(0,0)
		if is_on_wall():
			hurt(10)
		else:
        	damage_dealt=0
		if input.hide():
			hurt(1)
			linear_velocity = movedir.normalized() * HIDE_SPEED
		else:
			hurt(0)
			linear_velocity = movedir.normalized() * SPEED
		move_and_slide(linear_velocity, floor_normal)

#funcion que checkea si movedir se mueve y no es infinito para actualizar la posicion del spirte
func _spritedir_loop():
	if movedir != Vector2.ZERO && movedir != Vector2.INF:
		spritedir = movedir

#funcion que devueve el estado de stamina en funcion de delta(frames)
func _staminaRegen_loop():
	if inicioSegundo:
		if STAMINA<100:
			#print ("regenerating stamina")
			STAMINA+=STAMINA_REGEN


#funcion que devueve el health de stamina en funcion de delta(frames)
func _healthRegen_loop():
	if inicioSegundo && !DEATH && !hurted:
		if HEALTH<100:
			print ("regenerating health")
			HEALTH+=HEALTH_REGEN
			if HEALTH >100:
				HEALTH=100
			print ("HEALTH actual: ",int(HEALTH))

#funcion que devueve el health de stamina en funcion de delta(frames)
func _hurted_delay():
	if hurted && inicioSegundo:
		hurted=false
		print ("hurtedStatus= ", hurted)
		

#funcion que devuelve el estado de health en funcion de delta(frames)
func _healthstate_loop(damage_dealt):
	if DEATH==false:		
		if HEALTH<=0:
			print ("death")
			DEATH=true
			return false
		else:
			if damage_dealt && !hurted:
				HEALTH-=int(damage_dealt)
				print ("health after damage= ", HEALTH)
				hurted=true
				print ("hurtedStatus= ", hurted)
				return HEALTH


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
		return Input.is_action_just_pressed("ui_attack1")
	static func hide():
		return Input.is_action_pressed("ui_hide")

#funcion que describe el movimiento
func movement():
	movedir.x = -input.left() + input.right()
	movedir.y = -input.up() + input.down()

func hurt(damage):
	if !hurted:
		if damage!=0 && !hurted:
			damage_dealt=damage
			hurtedTIME=TIME
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