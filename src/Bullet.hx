package;
import haxor.component.Behaviour;
import haxor.core.Entity;
import haxor.core.Engine;
import haxor.math.Quaternion;
import haxor.math.Vector3;
import haxor.core.IUpdateable;
import haxor.input.*;
import haxor.core.Time;
import haxor.math.Mathf;
import physics.*;

class Bullet extends Behaviour implements IUpdateable implements ITriggerable
{
	public var myId : Int;
	public var game : Game;
	public var playerId : Int;
	public var color : Int;
	public var own : Bool;
	private static var margin = 100;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}
	
	public function OnUpdate():Void
	{
		transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), Math.atan2(rigidbody.velocity.y, rigidbody.velocity.x));
		
		if (transform.position.x < -margin ||
			transform.position.y < -margin ||
			transform.position.x > Game.width+margin ||
			transform.position.y > Game.height+margin)
		{
			game.removeBullet(myId);
		}
	}
	
	public function Trigger(c:Collider)
	{
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}