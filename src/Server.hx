import haxe.Json;
import haxe.Serializer;
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
}
class Bullet
{
	public function new(){}
	public var id : Int;
	public var color : Int;
	public var x : Float;
	public var y : Float;
	public var velX : Float;
	public var velY : Float;
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
}

class Server extends TCPServer
{
	public var players = new Map<Int, Player>();
	public var bullets = new Map<Int, Bullet>();
	public var enemies = new Map<Int, Enemy>();
	public var bulletsId = 0;
	public var enemiesId = 0;
	public var colors = [0x0367A6, 0x048ABF, 0x47A62D, 0xF2B84B, 0xD98D30];
	
	static function main()
	{
		var server = new Server(2014, false);
	}
	
	override function new(port : Int, debug : Bool)
	{
		super(port, debug);
		
		var timer = new haxe.Timer(1000);
		timer.run = function()
		{
			addEnemy();
		}
	}
	
	override function OnUserConnect(p_user : ServerUser) : Void 
	{
		super.OnUserConnect(p_user);
		
		for (player in players)
			p_user.Send( { code : Protocol.STC_ADDOTHERPLAYER, player : player } );
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
				case Protocol.CTS_ADDBULLET :		addBullet(p_user, Std.parseInt(p_user.id), p_data.x, p_data.y, p_data.velX, p_data.velY);
				case Protocol.CTS_REMOVEBULLET :	removeBullet(p_user, p_data.id);
				case Protocol.CTS_REMOVEENEMY :		removeEnemy(p_user, p_data.id);
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
		//player.color = colors[id % colors.length];
		player.color = id % 4;
		players.set(id, player);
		
		user.Send( { code : Protocol.STC_ADDSELFPLAYER, player : player } );
		
		for (otherUser in users)
			if (user != otherUser)
				otherUser.Send( { code : Protocol.STC_ADDOTHERPLAYER, player : player } );
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
	
	private function addBullet(user : ServerUser, id : Int, x : Float, y : Float, velX : Float, velY : Float)
	{
		var bullet = new Bullet();
		bullet.id = bulletsId++;
		bullet.x = x;
		bullet.y = y;
		bullet.velX = velX;
		bullet.velY = velY;
		bullets.set(bullet.id, bullet);
		
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_ADDBULLET, bullet : bullet } );
	}
	
	private function removeBullet(user : ServerUser, id : Int)
	{
		bullets.remove(id);
	}
	
	private function addEnemy()
	{
		var enemy = new Enemy();
		enemy.id = enemiesId++;
		enemy.color = colors[Std.random(colors.length)];
		enemy.x = 100 + Math.random() * 600;
		enemy.y = 100 + Math.random() * 400;
		enemy.velX = 0;
		enemy.velY = 0;
		enemies.set(enemy.id, enemy);
		
		for (otherUser in users)
			otherUser.Send( { code : Protocol.STC_ADDENEMY, enemy : enemy} );
	}
	
	private function removeEnemy(user : ServerUser, id : Int)
	{
		enemies.remove(id);
	}
}