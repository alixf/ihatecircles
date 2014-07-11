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
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}
	
	public function OnUpdate():Void
	{
		transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), Math.atan2(rigidbody.velocity.y, rigidbody.velocity.x));
		
		if (transform.position.x < -100 ||
			transform.position.y < -100 ||
			transform.position.x > 900 ||
			transform.position.y > 700)
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