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
		addPlayer(game.playerName, game.customGame ? "#"+game.customGameName : "lobby");
	}

	override private function OnData(p_data : String):Void
	{
		var data : Dynamic = Json.parse(p_data);
		var code : Int = cast data.code;
		
		switch(code)
		{
			case Protocol.STC_ADDPLAYER :			game.addPlayer(data.player.id, data.player.name, data.player.color, data.player.x, data.player.y, data.player.rotation, data.self);
			case Protocol.STC_UPDATEPLAYER :		game.updatePlayer(data.id, data.x, data.y, data.rotation, data.velX, data.velY);
			case Protocol.STC_REMOVEPLAYER :		game.removePlayer(data.id);
			case Protocol.STC_ADDBULLET : 			game.addBullet(data.bullet.id, data.bullet.playerId, data.bullet.x, data.bullet.y, data.bullet.velX, data.bullet.velY, data.own);
			case Protocol.STC_ADDENEMY :			game.addEnemy(data.enemy.id, data.enemy.color, data.enemy.x, data.enemy.y, data.enemy.velX, data.enemy.velY);
			case Protocol.STC_REMOVEMULTISCORE :	if (data.enemyId > 0) game.removeEnemy(data.enemyId);
													if (data.bulletId > 0) game.removeBullet(data.bulletId);
													if (data.score > 0) game.addScore(data.playerId, data.score);
			case Protocol.STC_STARTGAME :			game.startGame();
			case Protocol.STC_HITPLAYER : 			game.updateLife(data.playerId, data.health);
			}
	}

	public function addPlayer(name : String, game : String)
	{
		Send( { code : Protocol.CTS_ADDPLAYER, name : name, game : game} );
	}
	
	public function updatePosition(x : Float, y : Float, rotation : Float, velX : Float, velY : Float)
	{
		Send({code : Protocol.CTS_UPDATEPLAYER, x : x, y : y, rotation : rotation, velX : velX, velY : velY});
	}
	
	public function addBullet(playerId : Int, x : Float, y : Float, velX : Float, velY : Float)
	{
		Send({code : Protocol.CTS_ADDBULLET, playerId : playerId, x : x, y : y, velX : velX, velY : velY});
	}
	
	public function hitEnemy(enemyId : Int, bulletId : Int)
	{
		Send({code : Protocol.CTS_HITENEMY, enemyId : enemyId, bulletId : bulletId});
	}
	
	public function startGame()
	{
		Send( { code : Protocol.CTS_STARTGAME } );
	}
	
	public function hitPlayer(enemyId : Int)
	{
		Send( { code : Protocol.CTS_HITPLAYER, enemyId : enemyId } );
	}
}