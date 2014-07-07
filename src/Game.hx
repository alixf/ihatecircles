package;

//import openfl.*;
//import openfl.display.*;
//import openfl.events.*;
import haxor.core.*;
import haxor.math.Vector2;
import haxor.math.Vector3;
import haxor.component.RigidBody;
import haxor.component.Transform;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.Browser;
import js.html.Image;
import haxor.math.Quaternion;
import haxor.physics.Physics;

class Game extends Application implements IRenderable
{
	public var network : Network;
	public var canvas : CanvasRenderingContext2D;
	public var playerImages : Array<Image>;
	public var bulletImages : Array<Image>;
	public var players = new Map<Int, Entity>();
	public var bullets = new Map<Int, Entity>();
	
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
	}
	
	override function Initialize() : Void
	{
		var networkEntity = new Entity();
		network = cast networkEntity.AddComponent(Network);
		network.Connect("ws://localhost", 2014, "", 0, false);
		network.game = this;
		Network.instance = network;
		
		var canvasElement : CanvasElement = cast Browser.document.getElementById("canvas");
		canvas = canvasElement.getContext2d();
		
		stage.visible = false;
		if(canvas != null)
			Engine.Add(this);
		fps = 60;
		
		Physics.gravity = Vector3.zero;
		
		var backgroundEntity = new Entity();
		var background : Background = cast backgroundEntity.AddComponent(Background);
		background.canvas = canvas;
	}
	
	public function addPlayer(control : Bool, id : Int, name : String, color : Int, x : Float, y : Float, rotation : Float)
	{
		var player = new Entity();
		var imageRenderer = player.AddComponent(ImageRenderer);
		imageRenderer.canvas = canvas;
		imageRenderer.image = playerImages[color%4];
		var rigidbody = player.AddComponent(RigidBody);
		
		if (control)
		{
			var playerBehaviour = player.AddComponent(Player);
			playerBehaviour.game = this;
		}
		
		player.transform.position = new Vector3(x, y, 0.0);
		player.transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), rotation);
		
		players.set(id, player);
	}
	
	public function updatePlayer(id : Int, x : Float, y : Float, rotation : Float)
	{
		var player = players.get(id);
		player.transform.position = new Vector3(x, y, 0.0);
		player.transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), rotation);
	}
	
	public function removePlayer(id : Int)
	{
		var player = players.get(id);
		if (player != null)
		{
			Resource.Destroy(player);
			players.remove(id);
		}
	}
	
	public function addBullet(id : Int, x : Float, y : Float, velX : Float, velY : Float)
	{		
		var bullet = new Entity();
		bullet.transform.position = new Vector3(x, y, 0.0);
		
		var imageRenderer = bullet.AddComponent(ImageRenderer);
		imageRenderer.canvas = canvas;
		imageRenderer.image = bulletImages[0];
		
		bullet.AddComponent(RigidBody);
		bullet.rigidbody.velocity = new Vector3(velX, velY, 0.0);
		
		var bulletBehaviour = bullet.AddComponent(Bullet);
		bulletBehaviour.myId = id;
		bulletBehaviour.game = this;
		
		bullets.set(id, bullet);
	}
	
	public function removeBullet(id : Int)
	{
		var bullet = bullets.get(id);
		if (bullet != null)
		{
			Engine.Remove(bullet.GetComponent(Bullet));
			Engine.Remove(bullet.GetComponent(ImageRenderer));
			Engine.Remove(bullet.GetComponent(RigidBody));
			//Resource.Destroy(bullet);
			bullets.remove(id);
		}
	}
	
	public function OnRender():Void
	{
		canvas.clearRect(0, 0, 800, 600);
		//canvas.fillStyle="#DDDDDD";
		//canvas.fillRect(0,0,800,600);
	}
}