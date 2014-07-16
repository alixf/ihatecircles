package;

import haxor.core.*;
import haxor.math.Vector2;
import haxor.math.Vector3;
import haxor.component.RigidBody;
import haxor.component.Transform;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;
import js.html.Event;
import js.html.Image;
import haxor.math.Quaternion;
import physics.*;
import motion.Actuate;

class Game extends Application implements IRenderable implements IFixedUpdateable
{
	public var network : Network;
	public var canvasElement : CanvasElement;
	public var canvas : CanvasRenderingContext2D;
	public var playerImages : Array<Image>;
	public var bulletImages : Array<Image>;
	public var enemyImages : Array<Image>;
	public var readyAreaImage : Image;
	public var players = new Map<Int, Entity>();
	public var bullets = new Map<Int, Entity>();
	public var enemies = new Map<Int, Entity>();
	var playersIn = 0.0;
	var readyAreaImageRenderer : ImageRenderer;
	var readyArea : Entity;
	var gameStarted = false;
	
	
	public var playerName : String;
	public var customGame : Bool;
	public var customGameName : String;
	
	public static function main()
	{
	}
	
	override function Build() : Void
	{
		playerImages = [Asset.LoadImage("playerImage0", "assets/player0.png"),
						Asset.LoadImage("playerImage1", "assets/player1.png"),
						Asset.LoadImage("playerImage2", "assets/player2.png"),
						Asset.LoadImage("playerImage3", "assets/player3.png")];
		bulletImages = [Asset.LoadImage("bulletImage0", "assets/bullet0.png"),
						Asset.LoadImage("bulletImage1", "assets/bullet1.png"),
						Asset.LoadImage("bulletImage2", "assets/bullet2.png"),
						Asset.LoadImage("bulletImage3", "assets/bullet3.png")];
		enemyImages =  [Asset.LoadImage("enemyImage0", "assets/enemy0.png"),
						Asset.LoadImage("enemyImage1", "assets/enemy1.png"),
						Asset.LoadImage("enemyImage2", "assets/enemy2.png"),
						Asset.LoadImage("enemyImage3", "assets/enemy3.png")];
		readyAreaImage = Asset.LoadImage("readyArea", "assets/readyArea.png");
	}
	
	override function Initialize() : Void
	{
		var overlayElement = Browser.document.getElementById("overlay");
		var customGameCheckbox = Browser.document.getElementById("customGame");
		var customGameNameInput = Browser.document.getElementById("customGameName");
		var startGameButton = Browser.document.getElementById("startGame");
		var playerNameInput = Browser.document.getElementById("playerName");
		
		customGameCheckbox.addEventListener("change", function(event : Event)
		{
			var checked : Bool = untyped __js__("event.target.checked");
			customGameNameInput.setAttribute("style", checked ? "visibility : visible;" : "visibility : hidden;");
		});
		startGameButton.addEventListener("click", function(event : Event)
		{
			playerName = untyped __js__("playerNameInput.value");
			customGame = untyped __js__("customGameCheckbox.checked");
			customGameName = untyped __js__("customGameNameInput.value");
			overlayElement.setAttribute("opened", "false");
			Start();
		});
	}
	
	function Start()
	{
		var networkEntity = new Entity();
		network = cast networkEntity.AddComponent(Network);
		network.Connect("ws://192.168.0.11", 2014, "", 0, false);
		network.game = this;
		Network.instance = network;
		
		canvasElement = cast Browser.document.getElementById("canvas");
		canvas = canvasElement.getContext2d();
		
		stage.visible = false;
		if(canvas != null)
			Engine.Add(this);
		fps = 60;
		
		haxor.physics.Physics.gravity = Vector3.zero;
		
		var backgroundEntity = new Entity();
		var background : Background = cast backgroundEntity.AddComponent(Background);
		background.canvas = canvas;
		
		// Ready Area
		readyArea = new Entity();
		readyAreaImageRenderer = readyArea.AddComponent(ImageRenderer);
		readyAreaImageRenderer.canvas = canvas;
		readyAreaImageRenderer.image = readyAreaImage;
		readyArea.transform.position = new Vector3(400, 600 - 107);
	}
	
	public function addPlayer(id : Int, name : String, color : Int, x : Float, y : Float, rotation : Float, self : Bool)
	{
		var player = new Entity();
		var imageRenderer = player.AddComponent(ImageRenderer);
		imageRenderer.canvas = canvas;
		imageRenderer.image = playerImages[color % 4];
		imageRenderer.x = 10;
		imageRenderer.y = 0;
		
		var textRenderer = player.AddComponent(TextRenderer);
		textRenderer.fixedRotation = true;
		textRenderer.canvas = canvas;
		textRenderer.set_text(name); //FIXME
		
		var rigidbody = player.AddComponent(RigidBody);
		
		var collider = player.AddComponent(Collider);
		collider.radius = 15.0;
		
		var playerBehaviour = player.AddComponent(Player);
		playerBehaviour.game = this;
		playerBehaviour.myId = id;
		playerBehaviour.control = self;
		playerBehaviour.color = color % 4;
		
		player.transform.position = new Vector3(x, y, 0.0);
		player.transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), rotation);
		
		players.set(id, player);
		
		UI.instance.addPlayer(id, name);
	}
	
	public function updatePlayer(id : Int, x : Float, y : Float, rotation : Float, velX : Float, velY : Float)
	{
		var player = players.get(id);
		player.transform.position = new Vector3(x, y, 0.0);
		player.transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), rotation);
		player.rigidbody.velocity = new Vector3(velX, velY, 0.0);
	}
	
	public function removePlayer(id : Int)
	{
		var player = players.get(id);
		if (player != null)
		{
			Resource.Destroy(player);
			players.remove(id);
			UI.instance.removePlayer(id);
		}
	}
	
	public function addBullet(id : Int, playerId : Int, x : Float, y : Float, velX : Float, velY : Float, own : Bool)
	{
		var bullet = new Entity();
		bullet.transform.position = new Vector3(x, y, 0.0);
		
		var imageRenderer = bullet.AddComponent(ImageRenderer);
		imageRenderer.canvas = canvas;
		var color = players.get(playerId).GetComponent(Player).color;
		imageRenderer.image = bulletImages[color];
		
		bullet.AddComponent(RigidBody);
		bullet.rigidbody.velocity = new Vector3(velX, velY, 0.0);
		
		if (own)
		{
			var collider = bullet.AddComponent(Collider);
			collider.radius = 10.0;	
		}
		
		var bulletBehaviour = bullet.AddComponent(Bullet);
		bulletBehaviour.myId = id;
		bulletBehaviour.game = this;
		bulletBehaviour.playerId = playerId;
		bulletBehaviour.color = color;
		bulletBehaviour.own = own;
		
		bullets.set(id, bullet);
	}
	
	public function removeBullet(id : Int)
	{
		var bullet = bullets.get(id);
		if (bullet != null)
		{
			Resource.Destroy(bullet.GetComponent(Bullet));
			Resource.Destroy(bullet.GetComponent(RigidBody));
			Resource.Destroy(bullet.GetComponent(ImageRenderer));
			if(bullet.GetComponent(Collider))
				Resource.Destroy(bullet.GetComponent(Collider));
			bullets.remove(id);
		}
	}
	
	public function addEnemy(id : Int, color : Int, x : Float, y : Float, velX : Float, velY : Float)
	{
		var enemy = new Entity();
		enemy.transform.position = new Vector3(x, y, 0.0);
		
		var imageRenderer = enemy.AddComponent(ImageRenderer);
		imageRenderer.canvas = canvas;
		imageRenderer.image = enemyImages[color];
		
		enemy.AddComponent(RigidBody);
		enemy.rigidbody.velocity = new Vector3(velX, velY, 0.0);
		var collider = enemy.AddComponent(Collider);
		collider.radius = 50.0;
		
		var enemyBehaviour = enemy.AddComponent(Enemy);
		enemyBehaviour.myId = id;
		enemyBehaviour.game = this;
		enemyBehaviour.color = color;
		
		enemies.set(id, enemy);
	}
	
	public function removeEnemy(id : Int)
	{
		var enemy = enemies.get(id);
		if (enemy != null)
		{
			Resource.Destroy(enemy.GetComponent(ImageRenderer));
			Resource.Destroy(enemy.GetComponent(Collider));
			Resource.Destroy(enemy.GetComponent(Enemy));
			enemies.remove(id);
		}
	}
	
	public function startGame()
	{
		Actuate.update(function(x:Float,y:Float,z:Float){readyArea.transform.scale = new Vector3(x, y, z);}, 0.5, [1.0,1.0,1.0], [3.0,3.0,1.0]).ease(motion.easing.Expo.easeIn);
		Actuate.tween(readyAreaImageRenderer, 0.5, {opacity : 0});
		gameStarted = true;
	}
	
	public function addScore(playerId : Int, score : Float)
	{
		var player = players.get(playerId).GetComponent(Player);
		player.score += score;
		UI.instance.setPlayerScore(playerId, player.score);
	}
	
	public function OnFixedUpdate() : Void
	{
		Physics.Update();
		
		if (!gameStarted)
		{
			playersIn = 0.0;
			var playersCount = 0.0;
			for (player in players)
			{
				playersCount += 1.0;
				if (Vector3.Distance(player.transform.position, new Vector3(readyArea.transform.position.x, 600, 0)) <= 180)
					playersIn += 1.0;
			}
			if(playersCount > 0)
				playersIn = playersIn / playersCount;
		}
	}
	
	public function OnRender():Void
	{
		canvas.clearRect(0, 0, 800, 600);
		
		if (!gameStarted)
		{
			switch(playersIn)
			{
			case 0.0 : readyAreaImageRenderer.opacity = 0.25;
			case 1.0 :
					readyAreaImageRenderer.opacity = 1.0;
					network.startGame();
			case _ : readyAreaImageRenderer.opacity = 0.5 + (0.25 * Math.sin(Time.elapsed*5));
			}
		}
		
		//for (c in Physics.colliders)
		//{			
			//canvas.beginPath();
			//canvas.arc(c.transform.position.x + c.center.x, c.transform.position.y + c.center.y, c.radius * (c.transform.scale.x + c.transform.scale.y) / 2 +2, 0, 2 * Math.PI, false);
			//canvas.fillStyle = 'rgba(255,255,255,0.1)';
			//canvas.fill();
		//}
	}
}