#Librerias
extends KinematicBody2D


#Variables constantes
const SPEED = 120
const HIDE_SPEED = 40

#Objetos
var movedir = Vector2()
var spritedir = Vector2()

#funcion que controla el movimiento y las animaciones
func _physics_process(delta):
	controls_loop()
	movement_loop()
	spritedir_loop()
	
 
	if movedir != Vector2.ZERO:
	 	if is_on_wall():
	 		if test_move(transform, spritedir):
	    		anim_switch("Push")
	 	else: 
	 		anim_switch("Run")
	else:
		anim_switch("Idle")

#funcion que altera el movimiento en funcion de los inputs de teclado: proyecto/ajustes/mapa_de_entrada
func controls_loop():
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")
 
	movedir.x = -int(LEFT) + int(RIGHT)
	movedir.y = -int(UP) + int(DOWN)

#funcion que aplica el movimiento introducido (por controls_loop()) y normalizado a la constante SPEED
func movement_loop():
	var linear_velocity
	var floor_normal = Vector2(0,0)
	if Input.is_action_pressed("ui_hide"): 
		linear_velocity = movedir.normalized() * HIDE_SPEED
	else:
		linear_velocity = movedir.normalized() * SPEED
	move_and_slide(linear_velocity, floor_normal)

#funcion que checkea si movedir se mueve y no es infinito para actualizar la posicion del spirte
func spritedir_loop():
	if movedir != Vector2.ZERO && movedir != Vector2.INF:
		spritedir = movedir

#funcion que devuelve la direccion en string
func direction_to_string(direction:Vector2) -> String:
	if direction.x == -1:
		return "Left"
	elif direction.x == 1:
		return "Right"
	elif direction.y == -1:
		return "Up"
	return "Down"

#funcion que actualiza la animacion en funcion de la direccion
func anim_switch(anim):
	var newanim = str(anim,direction_to_string(spritedir))
	if $Anim.current_animation != newanim:
		$Anim.play(newanim)
		

	





