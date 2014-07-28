import haxe.Json;
import haxe.Serializer;
import haxe.Timer;
import haxor.net.server.TCPServer;
import haxor.net.server.ServerUser;
import data.Data;
import nodejs.fs.File;

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
	public var colors = [0x0367A6, 0x048ABF, 0x47A62D, 0xF2B84B];
	
	public var wave = 0;
	public var timer : Timer;
	public var startTime = 0.0;
	public var gameStarted = false;
	
	static function main()
	{
		var server = new Server(2014, false);
		
		#if js
		Data.load(File.readFileSync("data.cdb"));
		#else
		Data.load(haxe.Resource.getString("data.cdb"));
		#end
	}
	
	override function new(port : Int, debug : Bool)
	{
		super(port, debug);
	}
	
	
	private function startGame()
	{
		if (gameStarted)
			return;
			
		startTime = Timer.stamp();
		timer = new Timer(100);
		timer.run = function()
		{
			addEnemy();
		};
		
		gameStarted = true;
		
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_STARTGAME });
	}

	private function addEnemy()
	{
		var time = Timer.stamp() - startTime;
		var nextEnemy = Data.Enemies.all[wave];
		
		if (nextEnemy != null)
		{
			if (nextEnemy.time <= time)
			{
				wave++;
				
				var enemy = new Enemy();
				enemy.id = nextEnemy.index+1;
				
				switch(nextEnemy.position)
				{
				case data.Position.Fixed(x, y) :
					enemy.x = x; enemy.y = y;
				case data.Position.Random(x0, y0, x1, y1) :
					enemy.x = x0 + Math.random() * (x1 - x0);
					enemy.y = y0 + Math.random() * (y1 - y0);
				case data.Position.Circle(x, y, angle, radius) : 
					enemy.x = x + Math.cos(Math.PI * 2 * angle) * radius;
					enemy.y = y + Math.sin(Math.PI * 2 * angle) * radius;
				}
				
				for (color in nextEnemy.color)
					enemy.color = color.colors.toInt();
				
				enemy.velX = 0;
				enemy.velY = 0;
				enemy.health = nextEnemy.health;
				enemies.set(enemy.id, enemy);
				
				for (otherUser in users)
					otherUser.Send( { code : Protocol.STC_ADDENEMY, enemy : enemy} );
			}
		}
		
		
		
		
		
		//if (nextEnemy != null)
		//{
			//if (nextEnemy.time <= time)
			//{
				//wave++;
				//var enemy = new Enemy();
				//enemy.id = nextEnemy.data.id;
				//enemy.color = nextEnemy.data.color;
				//enemy.x = nextEnemy.data.x;
				//enemy.y = nextEnemy.data.y;
				//enemy.velX = nextEnemy.data.velX;
				//enemy.velY = nextEnemy.data.velY;
				//enemy.health = nextEnemy.data.health;
				//enemies.set(enemy.id, enemy);
				//
				//for (otherUser in users)
					//otherUser.Send( { code : Protocol.STC_ADDENEMY, enemy : enemy} );
			//}
		//}
	}
	
	override function OnUserConnect(p_user : ServerUser) : Void 
	{
		super.OnUserConnect(p_user);
		
		for (player in players)
			p_user.Send( { code : Protocol.STC_ADDPLAYER, player : player, self : false } );
	}
	
	override function OnUserDisconnect(p_user : ServerUser) : Void 
	{
		trace("remove user : " + p_user);
		trace("users count : " + users.length);
		
		super.OnUserDisconnect(p_user);
		
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
				case Protocol.CTS_ADDPLAYER :		addPlayer(p_user, Std.parseInt(p_user.id), p_data.name, p_data.game);
				case Protocol.CTS_UPDATEPLAYER :	updatePlayer(p_user, Std.parseInt(p_user.id), p_data.x, p_data.y, p_data.rotation, p_data.velX, p_data.velY);
				case Protocol.CTS_ADDBULLET :		addBullet(p_user, Std.parseInt(p_user.id), p_data.x, p_data.y, p_data.velX, p_data.velY);
				case Protocol.CTS_REMOVEBULLET :	removeBullet(p_user, Std.parseInt(p_user.id), p_data.id);
				case Protocol.CTS_HITENEMY :		hitEnemy(p_user, Std.parseInt(p_user.id), p_data.enemyId, p_data.bulletId);
				case Protocol.CTS_STARTGAME :		startGame();
				case Protocol.CTS_HITPLAYER :		hitPlayer(p_user, Std.parseInt(p_user.id), p_data.enemyId);
				case Protocol.CTS_ADDLINE :			addLine(p_user, Std.parseInt(p_user.id), p_data.x, p_data.y, p_data.angle);
			}
		}
	}
	
	private function addPlayer(user : ServerUser, id : Int, name : String, game : String)
	{
		var player = new Player();
		player.id = id;
		player.name = name;
		player.x = 800/2;
		player.y = 600/2;
		player.rotation = Math.random() * 2 * Math.PI;
		player.color = (id % colors.length) + 1;
		player.health = 3;
		players.set(id, player);
		
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
		
		try
		{
		for (otherUser in users)
			if (user != otherUser)
				otherUser.Send( { code : Protocol.STC_UPDATEPLAYER, id : player.id, x : player.x, y : player.y, rotation : player.rotation, velX : player.velX, velY : player.velY } );	
		}
		catch (e : Dynamic)
		{
			trace('Exception : $e');
		}
	}
	
	private function addBullet(user : ServerUser, playerId : Int, x : Float, y : Float, velX : Float, velY : Float)
	{
		var bullet = new Bullet();
		bullet.id = bulletsId++;
		bullet.playerId = playerId;
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
		var bullet = bulletId > 0 ? bullets.get(bulletId) : null;
		
		if (enemy != null)
		{
			if (bullet != null)
			{
				var bulletColor = players.get(bullet.playerId).color;
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
			else
			{
				var player = players.get(userId);
				if (enemy.color == player.color)
				{
					enemy.health -= 50;
					if (enemy.health < 0)
					{
						for (otherUser in users)
							otherUser.Send( { code : Protocol.STC_REMOVEMULTISCORE, bulletId : 0, enemyId : enemyId, score : 10, playerId : userId } );
					}
					else
					{
						for (otherUser in users)
							otherUser.Send( { code : Protocol.STC_REMOVEMULTISCORE, bulletId : 0, enemyId : 0, score : 1, playerId : userId } );
					}
				}
			}
		}
	}

	private function hitPlayer(user : ServerUser, userId : Int, enemyId : Int)
	{
		var player = players.get(userId);
		player.health--;
		
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_HITPLAYER, playerId : userId, health : player.health } );
	}
	
	private function addLine(user : ServerUser, userId : Int, x : Float, y : Float, angle : Float)
	{
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_ADDLINE, playerId : userId, x : x, y : y, angle : angle } );
	}
}