package;
import haxor.component.Behaviour;
import haxor.core.Entity;
import haxor.core.Engine;
import haxor.core.Resource;
import haxor.core.ICollidable;
import haxor.math.Quaternion;
import haxor.math.Vector3;
import haxor.core.IUpdateable;
import haxor.input.*;
import haxor.core.Time;
import haxor.math.Mathf;
import physics.*;
import motion.Actuate;

class Enemy extends Behaviour implements IUpdateable implements ITriggerable
{
	public var myId : Int;
	var game : Game;
	public var color : Int;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
		
		transform.scale = Vector3.zero;
		Actuate.update(function(x:Float, y:Float, z:Float) { transform.scale = new Vector3(x, y, z); }, 0.5, [0.0, 0.0, 0.0], [0.25, 0.25, 0.25]);
	}
	
	public function OnUpdate():Void
	{
		transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), Math.atan2(rigidbody.velocity.y, rigidbody.velocity.x));
	}
	
	public function Trigger(c : Collider)
	{
		var bullet : Bullet = c.GetComponent(Bullet);
		if (bullet != null)
		{
			Resource.Destroy(c.GetComponent(Collider));
			Network.instance.hitEnemy(myId, bullet.myId);
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}