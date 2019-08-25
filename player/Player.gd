#Librerias
extends KinematicBody2D


#Variables constantes
const SPEED = 120
const HIDE_SPEED = 40
const TIRED_SPEED = 10
var DEATH=false
var HEALTH=100
var STAMINA = 10
var TIME = 0
var HEALTH_REGEN=1
var STAMINA_REGEN=1
var damage=0
var counter=30
var TIME_AUX=0
var delay=false
var delay_time=0
var fps= 60
var inicio_segundo=false
var stamina=0
var stamina_cost=0
var time_start = OS.get_unix_time()
var time_now = 0
var tired = false
var texto_array = Array()
var texto_valor = Array()

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
	_time(TIME,TIME_AUX,delta)
	_movement_loop()
	_controls_loop()
	_healthstate_loop(damage_dealt)
	_staminastate_loop(stamina_cost)
	_spritedir_loop()
	_animloader_loop(delta)
	_healthRegen_loop()
	_staminaRegen_loop()
	_delay()
	_consolator_printer ()
	#print ("TIME_AUX: ",int(TIME_AUX))
	counter+=1
	inicio_segundo=false

	#TODO: _spritestate_loop()
	
func _logger_ (texto,valor):
		texto_array.append(texto)
		if valor !=null:
			texto_valor.append(valor)
		else:
			texto_valor.append("")

func _consolator_printer ():
	if inicio_segundo:
		_logger_("--------------------------",null)
		for i in range(0, texto_array.size()):			
			print (texto_array[i]+": ", texto_valor[i])
	texto_array.clear()
	texto_valor.clear()
	
func _time(TIME,TIME_AUX,delta):
	if counter == fps:
		_logger_ ("health: ", HEALTH)
		_logger_ ("stamina: ", STAMINA)
		pretty_time()
		counter=0
		inicio_segundo=true	
	
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
			hurt(0)
		if input.hide():
			tired(1)
			linear_velocity = movedir.normalized() * HIDE_SPEED
		if tired==true:
			hurt(1)
			linear_velocity = movedir.normalized() * TIRED_SPEED
		if input.hide()==false && tired==false:
			tired(0)
			hurt(0)
			linear_velocity = movedir.normalized() * SPEED	
		move_and_slide(linear_velocity, floor_normal)
		
		

#funcion que checkea si movedir se mueve y no es infinito para actualizar la posicion del spirte
func _spritedir_loop():
	if movedir != Vector2.ZERO && movedir != Vector2.INF:
		spritedir = movedir

#funcion que devueve el estado de stamina en funcion de delta(frames)
func _staminaRegen_loop():
	if inicio_segundo && !DEATH && !delay:
		if STAMINA<100 && tired==false:
			_logger_ ("regenerating stamina", STAMINA_REGEN)
			STAMINA+=STAMINA_REGEN
		elif STAMINA>100:
			STAMINA=100
			
#funcion que devueve el health de stamina en funcion de delta(frames)
func _healthRegen_loop():
	if inicio_segundo && !DEATH && !delay:
		if HEALTH<100:
			_logger_ ("regenerating health",HEALTH_REGEN)
			HEALTH+=HEALTH_REGEN
			if HEALTH >100:
				HEALTH=100
			

#funcion que devueve el health de stamina en funcion de delta(frames)
func _delay():
	if delay && inicio_segundo:
		delay=false
		_logger_ ("delayStatus= ", delay)
		

#funcion que devuelve el estado de health en funcion de delta(frames)
func _healthstate_loop(damage_dealt):
	if DEATH==false:
		if HEALTH<=0:
			_logger_ ("death", true)
			DEATH=true
		else:
			if damage_dealt && !delay:
				HEALTH-=int(damage_dealt)
				if HEALTH<=0:
					HEALTH=0
				delay=true
				return HEALTH

func _staminastate_loop(stamina_cost):
	if DEATH==false:
		_logger_ ("STAMINA",STAMINA)
		_logger_ ("tired",tired)
		_logger_ ("stamina_cost",stamina_cost)
		if STAMINA==0:
			tired=true
			_logger_ ("tired",true)
		elif STAMINA==0 && tired==true && stamina_cost==0:
			_logger_ ("staminastate_tired",false)
			tired=false
		else:
			_logger_ ("staminastate_tired",false)
			tired=false
			if stamina_cost && !delay:
				STAMINA-=int(stamina_cost)
				if STAMINA<0:
					STAMINA=0
				delay=true
				return STAMINA
		


################## MEMBER FUNCTIONS ##########################


#funcion tiempo
func pretty_time():
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	_logger_("elapsed : ", str_elapsed)

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

func tired(stamina):
	if !delay && stamina!=0:
		stamina_cost=stamina
		delay_time=TIME
		return stamina_cost
	else:
		stamina_cost=0
		return false


func hurt(damage):
	if damage!=0 && !delay:
		damage_dealt=damage
		delay_time=TIME
		return damage_dealt
	else:
		damage_dealt=0
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