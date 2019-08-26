extends KinematicBody2D

#Objetos
var movedir = Vector2()
var spritedir = Vector2()

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
# BOOLEANS
var DEATH=false
var TIRED=false
var inicio_segundo=false
var delay=false
#Variables entorno
var TIME = 0
var counterFps = 30
var fps = 60
var time_start = OS.get_unix_time()
var time_now = 0


func _process(delta):
	_movement_loop()
	_controls_loop()
	_animloader_loop(delta)
	counterFps += 1
	inicio_segundo = false




#funcion que aplica el movimiento introducido (por _controls_loop()) y normalizado a la constante SPEED
func _movement_loop():
	if DEATH==false:
		var linear_velocity = movedir.normalized() * SPEED
		var floor_normal = Vector2(0,0)
		if is_on_wall():
			health_modifier(-10)
		if TIRED==true:
			linear_velocity = movedir.normalized() * TIRED_SPEED	
		
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
		
func _delay():
	if delay && inicio_segundo:
		delay=false


##################### MEMBER FUNCTIONS ####################
		
func movement():
	movedir.x = -input.left() + input.right()
	movedir.y = -input.up() + input.down()
	
#funcion que actualiza la animacion en funcion de la direccion
func anim_switch(anim):
	var newanim = str(anim,action_to_String(spritedir))
	if $Anim.current_animation != newanim:
		$Anim.play(newanim)
		
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
	if DEATH:
		return "Die" #TODO: create "Die" animation
	return "Down" #TODO: create "Idle" animation  
	
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
		
func die():
	DEATH=true
	if DEATH:
		return true
	return false
	