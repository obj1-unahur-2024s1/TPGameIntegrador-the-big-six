import characters.*
import animacion.*
import menu.*
import wollok.game.*
import powerUps.*


object clock{
	const incrementRate = 4500 // milisegundos cada cuanto se ejecuta el speed up.
	const difficultyIncrease = 200  //Lo que se le resta al reloj. en ms
	var timer = 5000 // Timer comun que maneja cada cuanto se agregan bloques.
 	var powerUPSpawnRate = 5000 //Tiempo minimo que transcurre entre la aparicion de un powerUP
 	
	/* Por limitaciones de wollok al iniciar un evento no puedo cambiarle el timer cada cuanto
	 * este se ejecuta para saltarme esta limitaciones creo otro evento fijo que cancele el evento anterior
	 * y lo empiece nuevamente asi tiene el tiempo correcto. 
	 */
	var gameIsOver = false // Proteccion anti loop
 
	method incrementTickRate(){
		// Llamamos el evento
		game.onTick(incrementRate, "speedUpTickRate", { self.speedUpTimer() })
	}
 
	method speedUpTimer(){
		// Hace que el timer de espera entre bloque y bloque baje.
		timer = 150.max(timer - difficultyIncrease)
	}
	
	method speedDownTimer(){
		//Incrementa ligeramete el tiempo de espera entre la bajada de bloques
		timer+=100
	}
	
	method speedDownPowerUpSpawnRate(){//incrementa por un segundo el tiempo entre intentos de spawnear powerups
		game.removeTickEvent("powerUpSpawner")
		powerUPSpawnRate+=1000
		game.onTick(powerUPSpawnRate, "powerUpSpawner",{itemCreator.powerUpSpawner()})
	}
 
	method pushMoreBlocks(){
		game.onTick(timer, "addBlocks", { field.anotherRound()})
	}
	
	method spawnPowerUP(){//crea un nuevo block de powerup
		//console.println("Starting spawner")
		game.onTick(powerUPSpawnRate, "powerUpSpawner",{itemCreator.powerUpSpawner()})
	}
 
	method debug(){
		// Para calibrar el timer
		console.println("Tiempo Entre eventos: " + timer.toString())
	}
 
	method resetEvents(){
		game.removeTickEvent("addBlocks")
		self.pushMoreBlocks()
	}	
 
	method stopAllEvents(){
		// Se le agrego una proteccion para que no se ejecute multiples veces.
		if (!gameIsOver)
		{
			gameIsOver = true
			console.println("Se perdio, deteniendo eventos")
			console.println("Puntaje Final: " + field.player().puntaje().toString())
			// Iniciamos el gameOver y detenemos eventos.
			game.removeTickEvent("limitBreak")
			game.removeTickEvent("speedUpTickRate")
			game.removeTickEvent("addBlocks")
			game.removeTickEvent("powerUpSpawner")
			game.schedule(500, {field.gameOver()})
			//field.gameOver()
			gameOverScreen.iniciarAnimacion()
		}		
	}
}

object musicPlayer{
	const property backgroundMusic = game.sound("Sound/98.mp3")
	const property gameOverSound = game.sound("Sound/GameOver.mp3")
	const property menuButtonSound = "Sound/chimes.mp3"
	const property reloj = "Sound/chord.mp3"
	const property puntos = "Sound/dingA.mp3"
	const property defrag = "Sound/Heavy Machine Gun.mp3"
	
	// Se llama al iniciar el juego con la tecla Enter.
	method onStart(){
		// Iniciamos la musica
		backgroundMusic.shouldLoop(true)
		backgroundMusic.play() // Un schedule si queremos que la musica arranque sola.
		console.println("Currently Playing: backgroundMusic")
	}
	
	method gameOver(){
		backgroundMusic.stop()
		gameOverSound.shouldLoop(true) // Pato esta haciendo una animacion o algo
		gameOverSound.play()
	}
	
	// Reproduce sonidos como VFX que no se pueden detener o no necesitan referencia
	method playSoundOnce(soundName){
		game.sound(soundName).play()
	}
}

object gameOverScreen{	
	method iniciarAnimacion(){
		musicPlayer.gameOver() // Cambiamos de musica.
		gameOverAnimation.start()
	}
	
	// Para cumplir poliformismo
	method moveRight(){}
	method moveLeft(){}
	method enter(){ // Saca el juego.
		game.stop()
	}
}

// Un objeto util para debugear todo desde un solo lado.
object debugStick{
	var target = clock
	const targetList = [clock, inputManager, field.player(),field]
	var index = 0
	
	// Printea el debug del obj actual.
	method debug(){
		target.debug()
	}
	
	method nextDebug(){
		// Bucle entre los targets.
		index = (index + 1) % (targetList.size())
		
		target = targetList.get(index)
		console.println("Now Targetting: " + target.toString())
	}
}