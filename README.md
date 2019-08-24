# CMPF


RELEASE 1:

-animacion player
  animacion hide
  animacion attack1
  animacion dash
-animacion npc
  animacion movimiento
  animacion idle
  animacion die
  animacion attack1
-script Player:
  funcion dash:
    se va a desplazar (distancia:medianera-puerta)
    estado inmune: no te pueden hacer daño durante el dash
-script attack1
  ataque basico sin arma:
    power=10
-script npc:
  movimiento: persigue al player y cuando esta a rango ataca
  healt: 100

RELEASE 2:
  
