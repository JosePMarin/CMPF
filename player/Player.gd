#Librerias
extends KinematicBody2D

#Player

# SPEED
const SPEED = 120
const HIDE_SPEED = 40
const TIRED_SPEED = 10
# STAMINA
const MAX_STAMINA = 100
var STAMINA = 5
var STAMINA_REGEN = 1
# HEALTH
const MAX_HEALTH = 100
var HEALTH = 100
var HEALTH_REGEN = 1

#Booleanos
var inicio_segundo=false
var DEATH=false
var delay=false
var TIRED = false

#Variables status
var HEALTH_MOD = 0
var STAMINA_MOD = 0

#Variables entorno
var TIME = 0
var counterFps = 30
var fps = 60
var time_start = OS.get_unix_time()
var time_now = 0
var logger_text = Array()
var logger_value = Array()

#Objetos
var movedir = Vector2()
var spritedir = Vector2()


#funcion que checkea el estado del personaje para mostrar animaciones
func _ready():
	pass
	#TODO: state_machine = $AnimationTree.get(paremeters_player)

#funcion que controla el movimiento y las animaciones
func _physics_process(delta):
	TIME+=delta
	#START
	_time()
	_status_control()
	_movement_loop()
	_controls_loop()
	_spritedir_loop()
	_animloader_loop(delta)
	_consolator_printer ()
	#TODO: _spritestate_loop()
	#END
	counterFps += 1
	inicio_segundo = false
	
#funcion _status_control_end_
func _status_control():
	if inicio_segundo:
		# TODO modificadores del daño
		if (HEALTH <= 0):
			DEATH = true		
		if TIRED && !input.hide():
			stamina_modifier(1)
		if (STAMINA == 0):
			TIRED = true
			health_modifier(-1)
		if (STAMINA < MAX_STAMINA && STAMINA > 0 && !input.hide()):
			TIRED = false
			_logger_ ("regenerating stamina", STAMINA_REGEN)
			stamina_modifier(STAMINA_REGEN)
		if (HEALTH < MAX_HEALTH && HEALTH > 0 && !TIRED):
			_logger_ ("regenerating health", HEALTH_REGEN)
			health_modifier(HEALTH_REGEN)
		_logger_ ("TIRED stamina", TIRED)

#funcion que aplica el movimiento introducido (por _controls_loop()) y normalizado a la constante SPEED
func _movement_loop():
	if DEATH==false:
		var linear_velocity
		var floor_normal = Vector2(0,0)

		if is_on_wall():
			health_modifier(-10)
		if input.hide():
			stamina_modifier(-1)
			linear_velocity = movedir.normalized() * HIDE_SPEED
		if TIRED==true:
			linear_velocity = movedir.normalized() * TIRED_SPEED
		if input.hide() == false && TIRED == false:			
			linear_velocity = movedir.normalized() * SPEED
		move_and_slide(linear_velocity, floor_normal)
		
#funcion que altera el movimiento en funcion de los inputs de teclado: proyecto/ajustes/mapa_de_entrada
func _controls_loop():
	movement()
	#TODO: attak()

#funcion que checkea si movedir se mueve y no es infinito para actualizar la posicion del spirte
func _spritedir_loop():
	if movedir != Vector2.ZERO && movedir != Vector2.INF:
		spritedir = movedir

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


#######################################################
################## FUNCTIONS ##########################
#######################################################

#funcion que modifica el estado de stamina en funcion de condiciones del entorno
func stamina_modifier(STAMINA_MOD):
	if inicio_segundo:
		if STAMINA_MOD>0:
			STAMINA += STAMINA_MOD
			if STAMINA > 100:
				STAMINA = MAX_HEALTH
			return STAMINA
		if STAMINA_MOD<0:
			STAMINA += STAMINA_MOD
			if (STAMINA <= 0):
				STAMINA = 0
			return STAMINA	
	else:
		return false

#funcion que modifica el estado de health en funcion de condiciones del entorno
func health_modifier(HEALTH_MOD):
	if inicio_segundo:
		if HEALTH_MOD<0:
			HEALTH+=HEALTH_MOD
			if HEALTH<0:
				HEALTH=0
			return HEALTH
		if HEALTH_MOD>0:
			HEALTH+=HEALTH_MOD
			if HEALTH>MAX_HEALTH:
				HEALTH=MAX_HEALTH			
			return HEALTH
	else:		
		return false

#funcion que manda una señal al programa
func die():
	if DEATH == true:
		set_physics_process(false)
		#todo: cargar animacion muerte
		return true
	return false

#funcion que describe el movimiento
func movement():
	movedir.x = -input.left() + input.right()
	movedir.y = -input.up() + input.down()

#funcion para sincronizar las acciones con el tiempo real
func _delay():
	if delay && inicio_segundo:
		delay=false
		_logger_ ("delayStatus= ", delay)
		


################## UTILS FUNCTIONS ##########################

#funcion que printea en log el stamina y health (TODO sustituir esto por conexiones con healthbar y staminabar) y el tiempo forma formateada
func _time():
	if counterFps == fps:
		_logger_ ("health: ", HEALTH)
		_logger_ ("stamina: ", STAMINA)
		pretty_time()
		counterFps=0
		inicio_segundo=true	

#funcion que printea la informacion de tiempo de manera formateada
func pretty_time():
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	_logger_("elapsed : ", str_elapsed)

#funcion que almacena en un array los mensajes para enviar al log
func _logger_ (texto,valor):
	logger_text.append(texto)
	if valor !=null:
		logger_value.append(valor)
	else:
		logger_value.append("")

#funcion que formatea los mensajes printeados por _logger_()
func _consolator_printer ():
	if inicio_segundo:
		_logger_("--------------------------", null)
		for i in range(0, logger_text.size()):			
			print (logger_text[i]+": ", logger_value[i])
	logger_text.clear()
	logger_value.clear()

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

func _on_SwordHit_area_entered(area):
	if area.is_in_group("hurtbox"):
		pass#area.take_damage()
	return true