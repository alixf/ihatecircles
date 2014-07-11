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

class Enemy extends Behaviour implements IUpdateable implements ITriggerable
{
	var myId : Int;
	var game : Game;
	var color : Int;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
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
			Network.instance.hitEnemy(myId, bullet.myId);
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}