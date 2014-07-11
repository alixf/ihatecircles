import haxe.Json;
import haxe.Serializer;
import haxe.Timer;
import haxor.net.server.TCPServer;
import haxor.net.server.ServerUser;

class Player
{
	public function new(){}
	public var id : Int;
	public var color : Int;
	public var name : String;
	public var x : Float;
	public var y : Float;
	public var rotation : Float;
	public var velX : Float;
	public var velY : Float;
	public var health : Int;
}
class Bullet
{
	public function new(){}
	public var id : Int;
	public var playerId : Int;
	public var color : Int;
	public var x : Float;
	public var y : Float;
	public var velX : Float;
	public var velY : Float;
	public var power : Float;
}
class Enemy
{
	public function new(){}
	public var id : Int;
	public var color : Int;
	public var x : Float;
	public var y : Float;
	public var velX : Float;
	public var velY : Float;
	public var health : Float;
}

class Server extends TCPServer
{
	public var players = new Map<Int, Player>();
	public var bullets = new Map<Int, Bullet>();
	public var enemies = new Map<Int, Enemy>();
	public var bulletsId = 1;
	public var enemiesId = 1;
	public var colors = [0x0367A6, 0x048ABF, 0x47A62D, 0xF2B84B];
	
	public var wave = 0;
	public var enemyWaves =
	[
		{time : 0.100, 	data : { id : 1, color : 0, x : 100, y : 100, velX : 0, velY : 0, health : 5 }},
		{time : 0.200, 	data : { id : 2, color : 0, x : 150, y : 100, velX : 0, velY : 0, health : 5 }},
		{time : 0.300, 	data : { id : 3, color : 0, x : 200, y : 100, velX : 0, velY : 0, health : 5 }},
		{time : 0.600, 	data : { id : 4, color : 0, x : 200, y : 150, velX : 0, velY : 0, health : 5 }},
		{time : 0.700, 	data : { id : 5, color : 0, x : 200, y : 200, velX : 0, velY : 0, health : 5 }},
		{time : 0.800, 	data : { id : 6, color : 0, x : 150, y : 200, velX : 0, velY : 0, health : 5 }},
		{time : 1.000, 	data : { id : 7, color : 0, x : 100, y : 200, velX : 0, velY : 0, health : 5 }},
		{time : 1.100, 	data : { id : 8, color : 0, x : 100, y : 150, velX : 0, velY : 0, health : 5 }},
	];
	public var timer : Timer;
	public var startTime = 0.0;
	
	static function main()
	{
		var server = new Server(2014, false);
	}
	
	override function new(port : Int, debug : Bool)
	{
		super(port, debug);
	}
	
	
	private function startGame()
	{
		startTime = Timer.stamp();
		timer = new Timer(100);
		timer.run = function()
		{
			addEnemy();
		}
	}

	private function addEnemy()
	{
		var time = Timer.stamp() - startTime;
		var nextEnemy = enemyWaves[wave];
		
		if (nextEnemy != null)
		{
			if (nextEnemy.time <= time)
			{
				wave++;
				var enemy = new Enemy();
				enemy.id = nextEnemy.data.id;
				enemy.color = nextEnemy.data.color;
				enemy.x = nextEnemy.data.x;
				enemy.y = nextEnemy.data.y;
				enemy.velX = nextEnemy.data.velX;
				enemy.velY = nextEnemy.data.velY;
				enemy.health = nextEnemy.data.health;
				enemies.set(enemy.id, enemy);
				
				for (otherUser in users)
					otherUser.Send( { code : Protocol.STC_ADDENEMY, enemy : enemy} );
			}
		}
	}
	
	override function OnUserConnect(p_user : ServerUser) : Void 
	{
		super.OnUserConnect(p_user);
		
		for (player in players)
			p_user.Send( { code : Protocol.STC_ADDPLAYER, player : player, self : false } );
	}
	
	override function OnUserDisconnect(p_user : ServerUser) : Void 
	{
		super.OnUserDisconnect(p_user);
		
		trace("remove user : " + p_user);
		trace("users count : " + users.length);
		
		players.remove(Std.parseInt(p_user.id));
		
		for (user in users)
			if (p_user != user)
				user.Send( { code : Protocol.STC_REMOVEPLAYER, id : Std.parseInt(p_user.id) } );
	}
	
	override function OnUserMessage(p_user:ServerUser, p_data:Dynamic):Void
	{
		var code : Int = cast p_data.code;
		
		if (p_data.code != null)
		{
			switch(p_data.code)
			{
				case Protocol.CTS_ADDPLAYER :		addPlayer(p_user, Std.parseInt(p_user.id), p_data.name);
				case Protocol.CTS_UPDATEPLAYER :	updatePlayer(p_user, Std.parseInt(p_user.id), p_data.x, p_data.y, p_data.rotation, p_data.velX, p_data.velY);
				case Protocol.CTS_ADDBULLET :		addBullet(p_user, Std.parseInt(p_user.id), p_data.playerId, p_data.x, p_data.y, p_data.velX, p_data.velY);
				case Protocol.CTS_REMOVEBULLET :	removeBullet(p_user, Std.parseInt(p_user.id), p_data.id);
				case Protocol.CTS_HITENEMY :		hitEnemy(p_user, Std.parseInt(p_user.id), p_data.enemyId, p_data.bulletId);
			}
		}
	}
	
	private function addPlayer(user : ServerUser, id : Int, name : String)
	{
		var player = new Player();
		player.id = id;
		player.name = name;
		player.x = 100 + Math.random() * 600;
		player.y = 100 + Math.random() * 400;
		player.rotation = Math.random() * 2 * Math.PI;
		player.color = id % colors.length;
		players.set(id, player);
		
		if (startTime == 0.0)
			startGame();
		
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_ADDPLAYER, player : player, self : user == otherUser});
	}
	
	private function updatePlayer(user : ServerUser, id : Int, x : Float, y : Float, rotation : Float, velX : Float, velY : Float)
	{
		var player = players.get(id);
		player.x = x;
		player.y = y;
		player.velX = velX;
		player.velY = velY;
		player.rotation = rotation;
		
		for (otherUser in users)
			if (user != otherUser)
				otherUser.Send( { code : Protocol.STC_UPDATEPLAYER, id : player.id, x : player.x, y : player.y, rotation : player.rotation, velX : player.velX, velY : player.velY} );
	}
	
	private function addBullet(user : ServerUser, id : Int, playerId : Int, x : Float, y : Float, velX : Float, velY : Float)
	{
		if (id != playerId)
			return;

		var bullet = new Bullet();
		bullet.id = bulletsId++;
		bullet.playerId = id;
		bullet.x = x;
		bullet.y = y;
		bullet.velX = velX;
		bullet.velY = velY;
		bullet.power = 1;
		bullets.set(bullet.id, bullet);
		
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_ADDBULLET, bullet : bullet, own : otherUser == user } );
	}
	
	private function removeBullet(user : ServerUser, userId : Int, bulletId : Int)
	{
		bullets.remove(bulletId);
	}
	
	private function hitEnemy(user : ServerUser, userId : Int, enemyId : Int, bulletId : Int)
	{
		var enemy = enemies.get(enemyId);
		var bullet = bullets.get(bulletId);
		var bulletColor = players.get(bullet.playerId).color;
		
		if (enemy != null && bullet != null)
		{
			if (enemy.color == bulletColor)
			{
				enemy.health -= bullet.power;
				
				if (enemy.health < 0)
				{
					for (otherUser in users)
						otherUser.Send( { code : Protocol.STC_REMOVEMULTISCORE, bulletId : bulletId, enemyId : enemyId, score : 3, playerId : userId } );
				}
				else
				{
					for (otherUser in users)
						otherUser.Send( { code : Protocol.STC_REMOVEMULTISCORE, bulletId : bulletId, enemyId : 0, score : 1, playerId : userId } );
				}
			}
			else
			{
				for (otherUser in users)
					otherUser.Send( { code : Protocol.STC_REMOVEMULTISCORE, bulletId : bulletId, enemyId : 0, score : 0, playerId : userId } );
			}
		}
	}
}