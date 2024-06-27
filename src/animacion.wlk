import wollok.game.*
import characters.*
import timing.*


object gameOverAnimation{
	var frame = 1
	var counter = 1 // Al llegar a 60, cambia la imagen.
	
	method position() = game.origin()
	
	method start(){
		//evento que maneja la velocidad de los frames animados. 
		game.onTick(50, "gameOverAnimacion", {self.pasarFrame()})
		game.addVisual(self)	
	}
	
	method pasarFrame(){
		frame = ((frame) % 10) + 1
		counter += 1
		if (counter > 60){
			// Detenemos el evento y la musica
			game.removeTickEvent("gameOverAnimacion")
			score.gameOver() // Muestra el score final
			musicPlayer.gameOverSound().stop()
		}
	}
	
	method image(){
		return if (counter <= 60) "GameOver/gameOver_" + frame.toString() + ".png"
		else "GameOver/GameOverMan2.png"
	}
}

object loading{
	var property position = game.at(0,13)
	var i = 0
	var nivel = 0
	var property image =  "Barra/Barra" + i.toString() + ".png"
	
	method sumarI(){
		i = i + 1
		image = "Barra/Barra" + i.toString() + ".png"
		if(i >= 45){
			// cambio de nivel
			i = 0
			nivel = 5.min(nivel + 1)
			background.image("Background/Background"+nivel.toString()+".png")
			
			//incrementa tiempo de espera para spawn de power ups
			clock.speedDownPowerUpSpawnRate()
			// agragamos dialogo y comienzo de animacion a partir de completar la barra loading
			game.say(charlatanInvisible,"Nivel "+ nivel.toString() + " alcanzado")
			clippy.cambiarC()
		}
		//se implementa un  reset para que clippy pueda volver a animarse en cada nuevo nivel que superamos
		if (i == 22) { clippy.resetearCounterC() }
	}
}



// Mascota que te motiva.
object clippy{
	var c = 171
	var counter = 0
	var property image = "Clippy/clippyanim" +  c.toString() + ".png"
	var property position = game.at(8,13)
	method sumarC(){
		c = c + 1
		image = "Clippy/clippyanim" +  c.toString() + ".png"
		counter += 1
		if (c >= 172) {c = 0}
		if (counter >= 172) {game.removeTickEvent("animar")}
	}
	method cambiarC(){
		game.onTick(50,"animar",{ self.sumarC() })
	} 
	method resetearCounterC(){
		counter = 0
	}
}

//Creamos un nuevo objeto para el dialogo de clippy por cuestiones meramente esteticas.
object charlatanInvisible{
	var property position = game.at(10,14)
	const charlatanDice = ["Que quilombo!","Esto se pone mas dificil","Parece que nos tenemos que apurar",
	"Aprovecha los powerups!","Apurate o vas a perder"]
	
	var charlatan = charlatanDice.anyOne()
	method mensaje() {
		const otraFrase = charlatanDice.filter({frase => frase != charlatan })
		charlatan = otraFrase.anyOne()
	}
	method mensajeCharlatan() {
		game.onTick(10200,"habla",{self.mensaje() game.say(self,charlatan)})
	}
}


// Imagen detras del clippy.
object background{
	var property image = "Background/Background.png"
	const property position = game.origin()
}
