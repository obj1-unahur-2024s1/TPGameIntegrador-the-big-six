import wollok.game.*
import menu.*
import animacion.*
import timing.*


object score{
	const board=[]
	
	method show(){
		console.println("iniciando Show")
		// Creamos los digitos del display y los mostramos
		(0..3).forEach({i => board.add(new ScoreDigit(decimal = i))})
		(0..3).forEach({i => game.addVisual(board.get(i))})
	}
	
	method updateScore(puntaje){
		// Arreglamos la lengitud del string para que sea siempre 4.
		const extraDigits = 4 - puntaje.toString().length()
		// Creamos un nuevo string con el puntaje.
		var newScore = ""
		(1..extraDigits).forEach({i => newScore += "0"})
		newScore += puntaje.toString()
		//console.println("New score: " + newScore)
		// Updateamos el score pasandole a cada digito el correspondiente index.	
		(0..3).forEach({index => board.get(index).updateScoreDigit(newScore.charAt(index))})
	}
	
	method gameOver(){
		board.forEach({digit => game.removeVisual(digit)})
		board.forEach({digit => digit.gameOver()})
		board.forEach({digit => game.addVisual(digit)})
	}
}

class ScoreDigit{
	const decimal
	var image = "Score/0.png"
	var position = game.at(decimal + 1, game.height()-1)
	
	method position() = position
	
	method gameOver(){
		position = game.at(decimal + 3, 1)
	}
		
	method image() = image
	
	// Cambia la imagen del digito por la que le pasemos.
	method updateScoreDigit(digit){
		image = "Score/" + digit + ".png"
	}
	
	method debug(){
		console.println(decimal.toString() + " Pos (" + self.position().x().toString() + ", " + self.position().y().toString() + ")")
	}
}

class Player{
	var puntaje = -1 // Empieza en -1 xq necesitamos un clear line , x ende pasa a 0.
	var property image = "Player/TxT.png"
	var property position = game.origin()
	var canShoot = false
 
	method moveLeft(){
		const newX = position.left(1).x().max(0)
		position = game.at(newX, 0)
		indicador.updatePositionIndicador()
		image = "Player/TxT1.png"
		//console.println("LEFT" + newX.toString())
	}
 
	method moveRight(){
		const newX = position.right(1).x().min(9)
		//console.println("RIGHT" + newX.toString())
		position = game.at(newX, 0)
		image = "Player/TxT.png"
		indicador.updatePositionIndicador()
	}
	
	method enter(){	} // para poliformismo
 
	method shoot(){
		if (canShoot) field.addBlock(position.x()) // Va de 0 a 9
	}
 
	method canShoot(value){
		canShoot = value		
	}
	
	method sumarPuntaje(x){
		puntaje += x
		score.updateScore(puntaje)
	}
	
	method puntaje() = puntaje
	
	method debug() 
	{
		console.println("Score: " + puntaje.toString())
	} 
}

class PowerUpPlayer inherits Player { //version del player con power up
	method timer(){
		// Seteamos la imagen del power up
		image = "Player/coolTxT1.png"
		//5 segundos para volver al player comun
		game.schedule(4300, {
			// Si termino el juego no se ejecuta para no romper todo. 
			if(!game.hasVisual(gameOverAnimation))
			{
				const oGPosition = field.player().position()
				const oGPuntaje = field.player().puntaje()
				const normalPlayer = new Player(position=oGPosition, canShoot=true, puntaje=oGPuntaje)
				field.changePlayer(normalPlayer)
			}
		})
	}
	
	override method moveLeft()
	{
		super()
		image = "Player/coolTxT1.png"
	}
	
	override method moveRight(){
		super()
		image = "Player/coolTxT.png"
	}
	
	override method shoot() {
		if (canShoot) field.destroyBrick(position.x())
	}
}
 
object field{
	const property colums = []
	var property player = new Player()
	const property activePowerUps = []
	
	// Inicialisamos 9 columnas , con pos 0 a 9.
	method initilize() {
		(0..9).forEach({i => colums.add(new Colum(position = i))})
		// A cada columna , le decimos que empiece con 1 , 2 o 3 ladrillos.
		colums.forEach({c => c.randomizeStack()})
	}
	
 	method changePlayer(newPlayer){
		//quito imagen del player anterior
		game.removeVisual(self.player())
		//creo nuevo player con powerup
		self.player(newPlayer)
		//creo la nueva visual
		game.addVisual(self.player())
		//cambio el controlador
		inputManager.controlling(self.player())
 	}
 	
	method addBlock(x){
		colums.get(x).addBlock()
	}	
 
	method lineCheck(x){
		// Si hay mas bloques en todas las columnas que el valor que le pasamos.
		if(colums.all({c => c.stack().size() - 1 >= x})){
			// Me fijo si toda la linea tiene un bloque en esa lineaY
			if(colums.all({c => c.blockInPosition(x)}))
			{
				//console.println("Se ejecuto el clear de linea")
				self.clearLine(x)
			} 
		}
		// Revisamos si perdimos
		const maxBlocks = 11
		if(colums.any({c => c.stack().size() > maxBlocks})){
			// Si nos pasamos del maximo , perdemos
			clock.stopAllEvents()
			player.canShoot(false)
			inputManager.controlling(gameOverScreen) // Cambiamos el control al de GameOver
		}
	}	
 
	method clearLine(y){
		// Borramos todo en la linea.
		colums.forEach({c => c.deleteBlock(y)})
		player.sumarPuntaje(1)
		loading.sumarI()
	}
 
	method anotherRound(){
		// Este metodo crea una nueva oleada de bloques.
		colums.forEach({c => if ([true,false].anyOne()) c.addBlock()})
	}
 
	method debug(){
		colums.forEach({c => console.println("S: " + c.stack().size().toString())})
		console.println("----------------")
	}
	
	//Si tenemos powerup destructor podemos destruir bloques de una columna directamente
	method destroyBrick(x){
		colums.get(x).destroyLastBrickInLane()
		// Le damos 1 punto por bloque destruido
		self.player().sumarPuntaje(1)
	}
	
	method gameOver(){
		// Remueve las visuales de los ladrillos al terminar el juego.
		colums.forEach({c => c.gameOver()})
		// Remuevo todos los power ups.
		activePowerUps.forEach({ p => p.destroy()})
		activePowerUps.clear()
	}
}
 
class Colum{
	const property position
	var property stack = [new Brick(position = game.at(position, 11)),
		new Brick(position = game.at(position, 10)),
		new Brick(position = game.at(position, 9))]
 
	method randomizeStack() {
		stack = stack.take((1..3).anyOne())
	}
 
	method blockInPosition(x) = stack.any({brick => brick.position().y() == (11 - x)}) // Arriba 5 - Abajo 0
 	
	method addBlock(){
		stack.add(new Brick(position = game.at(position, 11 - stack.size())))
		game.addVisual(stack.last())	
		// Al agregar un bloque revisamos si se completo alguna.
		const lineY = stack.size() - 1 
		field.lineCheck(lineY)	
	}
 
	method deleteBlock(x){ // Usado para limpiar lineas
		//console.println("Tratando de borrar " + x.toString())
		const target = 11 - x
		// Encontramos los objs a remover
		const basura = stack.find({brick => brick.position().y() == target})
		// Borramos la visual.
		game.removeVisual(basura)
		// Nos fijamos en el stack y sacamos el bloque con el matching Y.
		stack.remove(basura)
		// Reacomodamos las que queden x abajo de esa linea
		self.stackUp(target)
	}
	
	method stackUp(nivelY){
		// Para el stack de la columna, si esta x debajo del nivelDeY, lo muevo para arriba 1.
		stack.filter({brick => brick.position().y() < nivelY}).forEach({brick => brick.moveUp()})
	}
	
	//remueve el ultimo elemento de la columna , para power ups.
	method destroyLastBrickInLane(){
		//chequeo que la columna so este vacia
		if(not stack.isEmpty()){
			//busco el ultimo elemnto de la columna
			const target=stack.last()
			//limpio el Brick
			target.clear()
			//los saco del listado del stack
			stack.remove(target)
		}
	}
	method gameOver(){
		stack.forEach({ brick => game.removeVisual(brick)})
	}
}
 
class Brick{
	const imageList = ["Agent.png","Buscamina.png", "Compu.png","Directorio.png",
  		"directx.png", "File.png", "Papelera.png", "Pc.png"]
  	var image = "Icons/" + imageList.anyOne()
	var position 
	
	method image() = image
	
	method position() = position 
 
	method moveUp(){
		position = position.up(1)
	}
 
	method clear(){
		image = ""
		game.removeVisual(self)
	}
}

// Objeto Mira , marca donde se va a colocar el bloque.
object indicador{
	var playerX = field.player().position().x()
	method image() = "Indicador2.png"
	method position() = game.at(playerX, 11 - field.colums().get(playerX).stack().size())
	
	method updatePositionIndicador(){
		playerX = field.player().position().x()
	}
}

 
