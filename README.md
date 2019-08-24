# CMPF

-------------------------------------------------------
RELEASE 1:
-------------------------------------------------------
-animacion player:
  animacion hide ->in progress
  animacion idle -> in progress 
  animacion die
  animacion hurt
  animacion attack1 
  animacion dash
  animacion push
  animacion attackchain
-------------------------------------------------------
-animacion npc:
  animacion movimiento -> Done
  animacion idle -> in progress
  animacion hurt
  animacion die
  animacion attack1
-------------------------------------------------------
-script Player:
  func attack1:
    ataque basico sin arma:
    DAMAGE=10
  func attackchain:
    si 3 golpes seguidos en npc
      animacion attackchain
      DAMAGE=20
  func STAMINA: 
    STAMINA=100
    regenera 1 stamina por sec
    if npc = die 
      stamina +20
  funcion dash:
    STAMINACOST=30
    se va a desplazar (distancia:medianera-puerta)
    estado inmune: no te pueden hacer daño durante el dash
  funcion push:
    si estoy al lado de un objeto movible, lo mueve a velocidad SPEEDPUSH=SPEEDHIDE en todas direcciones
-------------------------------------------------------
-script npc:
  movimiento: persigue al player y cuando esta a rango ataca
  healt: 100
  func attack1:
    ataque basico sin arma
    DAMAGE=20
-------------------------------------------------------

RELEASE 2:
-------------------------------------------------------
-animacion player:
  animacion talk
  animacion attackrange
-------------------------------------------------------
-script Player:   
  funcion talk:
  func attackrange:
    DAMAGE variable en funcion de carga
      si carga = 0:
        DAMAGE=5
      si carga = 100:
        DAMAGE=100
-------------------------------------------------------
