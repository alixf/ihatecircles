package;
import haxor.component.Behaviour;
import haxor.core.Entity;
import haxor.core.Engine;
import haxor.core.ICollidable;
import haxor.math.Quaternion;
import haxor.math.Vector3;
import haxor.core.IUpdateable;
import haxor.input.*;
import haxor.core.Time;
import haxor.math.Mathf;
import haxor.physics.Collider;

class Enemy extends Behaviour implements IUpdateable implements ICollidable
{
	var myId : Int;
	var game : Game;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}
	
	public function OnUpdate():Void
	{
		transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), Math.atan2(rigidbody.velocity.y, rigidbody.velocity.x));
	}
	
	public function OnCollisionEnter(c:Collision)
	{
		trace("collision enter");
	}
	
	public function OnCollisionExit(c:Collision)
	{
		trace("collision exit");
	}
	
	public function OnCollisionStay(c:Collision)
	{
		trace("collision stay");
	}
}