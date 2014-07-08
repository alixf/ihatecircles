import haxe.Json;
import haxor.net.client.ClientUser;
import haxor.core.JSON;
import haxor.core.Console;

class Network extends haxor.net.client.Network
{
	static public var instance : Network;
	
	public var game : Game;
	
	override private function OnConnect():Void 
	{
		addPlayer("player#"+Std.random(10));
	}

	override private function OnData(p_data : String):Void
	{
		var data : Dynamic = Json.parse(p_data);
		var code : Int = cast data.code;
		
		switch(code)
		{
			case Protocol.STC_ADDSELFPLAYER :	game.addPlayer(true, data.player.id, data.player.name, data.player.color, data.player.x, data.player.y, data.player.rotation);
			case Protocol.STC_ADDOTHERPLAYER :	game.addPlayer(false, data.player.id, data.player.name, data.player.color, data.player.x, data.player.y, data.player.rotation);
			case Protocol.STC_UPDATEPLAYER :	game.updatePlayer(data.id, data.x, data.y, data.rotation, data.velX, data.velY);
			case Protocol.STC_REMOVEPLAYER :	game.removePlayer(data.id);
			case Protocol.STC_ADDBULLET : 		game.addBullet(data.bullet.id, data.bullet.x, data.bullet.y, data.bullet.velX, data.bullet.velY);
			case Protocol.STC_ADDENEMY :		game.addEnemy(data.enemy.id, data.enemy.color, data.enemy.x, data.enemy.y, data.enemy.velX, data.enemy.velY);
			//case Protocol.STC_UPDATEENEMY :		;
			//case Protocol.STC_REMOVEENEMY :		;
		}
	}

	public function addPlayer(name : String)
	{
		Send( { code : Protocol.CTS_ADDPLAYER, name : String } );
	}
	
	public function updatePosition(x : Float, y : Float, rotation : Float, velX : Float, velY : Float)
	{
		Send({code : Protocol.CTS_UPDATEPLAYER, x : x, y : y, rotation : rotation, velX : velX, velY : velY});
	}
	
	public function addBullet(x : Float, y : Float, velX : Float, velY : Float)
	{
		Send({code : Protocol.CTS_ADDBULLET, x : x, y : y, velX : velX, velY : velY});
	}
}