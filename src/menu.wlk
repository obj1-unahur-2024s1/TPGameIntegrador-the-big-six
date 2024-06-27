import wollok.game.*
import characters.*
import animacion.*
import timing.*


// Creamos los objetos que componen el menu
object menu {		
	method inicio(){
		game.addVisual(fondoDeNachito)
		game.addVisual(botonStart)
		game.addVisual(botonGuia)
		game.addVisual(botonSalir)
		game.addVisual(mouse)
		inputManager.controlling(mouse) //le indico que controlo el cursor del mouse
	}
}

object guia {
	var property image = "Menu/guia2.png"
	var primeraPantalla = true
	method position() = game.at(0,0)
	// Metodos para cumplir el poliformismo de Input Manager
	method moveRight(){}
	method moveLeft(){}
	method enter()
	{
		if(primeraPantalla){
			image = "Menu/guia3.png"
			primeraPantalla = false
		}else{
			// Arrancamos el juego.
			botonStart.startGame()
			game.removeVisual(self)
		}
	}
}

//fondo para el menu
object fondoDeNachito {
	const property image = "Menu/NachitoTxt.png"
	method position() = game.at(0,0)
}

//boton de start en menu
object botonStart{
	method position() = game.at(1,1)
	
	method image(){
		return if (mouse.position().x().between(1,3)) "Menu/boton1_apretado.png"
		else "Menu/boton1.png"
	}
	
	method startGame()
	{
		// Sacamos las cosas del menu
		game.removeVisual(fondoDeNachito)
		game.removeVisual(self)
		game.removeVisual(botonGuia)
		game.removeVisual(botonSalir)
		game.removeVisual(mouse)
		// Creamos el player
		game.addVisual(background)
		game.addVisual(field.player())
		game.addVisual(loading)
		field.player().canShoot(true) //habilita al jugador a disparar
		inputManager.controlling(field.player()) //cambia a controlar al icono del jugador
		score.show()
		//creamos a clippy
		game.addVisual(clippy)
		// Creamos el field
		field.initilize()
		//creamos y activamos los mensajes de clippy
		game.addVisual(charlatanInvisible)
		game.say(charlatanInvisible,"Hay que arreglar esto rapido")
		charlatanInvisible.mensajeCharlatan()
		// Creamos los bloques.
		field.colums().forEach({colum => colum.stack().forEach({brick => game.addVisual(brick)})})
		field.clearLine(0)
		// Iniciamos el reloj y empujamos bloques!
		clock.incrementTickRate()
		clock.pushMoreBlocks()
		clock.spawnPowerUP()
		game.onTick(5100, "limitBreak", { clock.resetEvents() })
		game.addVisual(indicador)
		// Iniciamos la musica
		musicPlayer.onStart()
	}
}

//boton guia en menu
object botonGuia{
	method position() = game.at(4,1)	
	method image(){
		return if (mouse.position().x().between(4,6)) "Menu/boton2_apretado.png"
		else "Menu/boton2.png"
	}
}

//boton de salir de juego en menu
object botonSalir{
	method position() = game.at(7,1)
	method image(){
		return if (mouse.position().x().between(7,9)) "Menu/boton3_apretado.png"
		else "Menu/boton3.png"
	}
}

//objeto puntero de mouse
object mouse{
	const property image = "Menu/mouse.png"
	var property position = game.at(0,1)
	var tocoDerecha = false
 
	method moveLeft(){
		const newX = position.left(3).x().max(0)
		position = game.at(newX, 1)
		if (self.position().x().between(1,9))
		{
			musicPlayer.playSoundOnce(musicPlayer.menuButtonSound())
			tocoDerecha = false
		}
	}
 
	method moveRight(){
		const newX = position.right(3).x().min(9)
		position = game.at(newX, 1)
		if (self.position().x().between(1,9)) 
		{
			// Para evitar multiples ping a la derecha
			if(!tocoDerecha)
			{
				musicPlayer.playSoundOnce(musicPlayer.menuButtonSound())
				// Si esta sobre el ultimo boton
				if(self.position().x() == 9){ 
					tocoDerecha = true
				}
			}			
		}		
	}
	//funciones al hacer click en cosas
	method enter(){
		// Boton Start
		if (self.position().x().between(1,3))
		{
			botonStart.startGame()
		}
		// Boton Guia
		if (self.position().x().between(4,6))
		{
			inputManager.controlling(guia) // Cambio el control al menu de guia.
			game.addVisual(guia)
		}
		// Boton Salir.
		if (self.position().x().between(7,9))
		{
			game.stop()
		}
	}
}

object inputManager{
	var property controlling 
	method controlling() = controlling
	// Se podria hacer un setter para controlling , pero luego se entiende menos en el resto del codigo.
	// Asi nos ahorrariamos un monton de metodos.
	
	method pressRight(){
		controlling.moveRight()
	}
	
	method pressLeft(){
		controlling.moveLeft()
	}
	method pressEnter(){
		controlling.enter()
	}	
	
	method debug(){
		console.println("What is the manager doing: " + controlling.toString())
	}
}


