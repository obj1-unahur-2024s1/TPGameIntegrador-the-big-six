import characters.*
import wollok.game.*
import timing.*

class PowerUp{ //version generica de power up para poder implementar distintas subclases
	var position = game.at((0..game.width()-1).anyOne(), game.height()-6)
	var isAlive = true //control contra doble llamada a remove visual
	method position() = position
	
	method goDown(){
		position = position.down(1)
		if(position.y() < -3 and isAlive){ //Chequeo si salio del area de juego, en cuyo caso lo elimino lo hago mas abajo para evitar casos en los que se ejecuta simultaneament con activate()
			game.removeVisual(self)
			game.removeTickEvent(self.identity().toString())
			field.activePowerUps().remove(self) // Lo quito de la lista.
			isAlive = false
		}
	}
	
	method timer(){
		game.onTick(500, self.identity().toString(), {self.goDown()})
	}
	
	method activate(){
		//Quito visual y evento de caida del powerup
		if(isAlive){
			game.removeVisual(self)
			game.removeTickEvent(self.identity().toString())
			isAlive = false
		}
	}
	
	method destroy(){
		// Evitamos que baje y le sacamos la visual.
		game.removeTickEvent(self.identity().toString())
		game.removeVisual(self)
	}
}

class Shooter inherits PowerUp{ //power up que destruye bloques
	method image() = "PowerUps/defrag.png"
	override method activate(){
		super()
		//recuerdo la posicion y puntaje original del player anterior
		const oGPosition = field.player().position()
		const oGPuntaje = field.player().puntaje()
		const newPlayer = new PowerUpPlayer(position=oGPosition, canShoot=true, puntaje=oGPuntaje)
		//cambio a estado de power up
		field.changePlayer(newPlayer)
		// comienzo conteo de tiempo de powerup
		field.player().timer()
		// activo el audio
		musicPlayer.playSoundOnce(musicPlayer.defrag())
	}
}

class Points inherits PowerUp{ // Este simplemente le suma puntos extra
	method image() = "PowerUps/10puntos.png"
	
	override method activate(){
		super()
		field.player().sumarPuntaje(10)
		// activo el audio
		musicPlayer.playSoundOnce(musicPlayer.puntos())
	}
}
 
class SlowDown inherits PowerUp{ //Disminuye ligeramente la velocidad en la que bajan los bloques
	method image() = "PowerUps/reloj.png"
		override method activate(){
		super()
		clock.speedDownTimer()
		// activo el audio
		musicPlayer.playSoundOnce(musicPlayer.reloj())
	}
}
 
object itemCreator{ 
	// Crea los distintos powerups
	const powerUps = [0, 1, 2]
	
	method createPowerUp(){
		const select = powerUps.anyOne()
		const newPowerup =
			if(select == 0) new Points()
			else if(select == 1) new Shooter()
			else new SlowDown()
		// Lo agregamos a la lista de power ups.
		field.activePowerUps().add(newPowerup)
		return newPowerup
	}
	
	method powerUpSpawner(){
		//cada vez que llega el tick solo tiene 1/3 chances de que se cree un nuevo powerup
		if([0,1,2].anyOne() == 1){
			//creo el nuevo power up
			const spawn = self.createPowerUp() 
			game.addVisual(spawn)
			//comienzo su timer
			spawn.timer() 
			game.whenCollideDo(spawn, {x => //controlo si coliciona con algo 
				if (x.position().y() == 0){// solo si coliciono con algo en la posicion 0 o sea el jugador y no un bloque
					spawn.activate()
					field.activePowerUps().remove(spawn) // Lo quito de la lista.
				}
			})
		}
	}
}