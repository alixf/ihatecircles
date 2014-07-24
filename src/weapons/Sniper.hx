package weapons;

import haxor.core.Engine;
import haxor.core.IUpdateable;
import haxor.core.Entity;
import haxor.component.Behaviour;
import haxor.input.Input;
import haxor.input.KeyCode;
import haxor.core.Time;
import physics.Physics;

class Sniper extends Behaviour implements IUpdateable
{
	public var reloadTime = 1.67;
	private var reloadClock = 0.0;
	public var bulletSpeed = 1000;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}
	
	public function OnUpdate():Void
	{
		reloadClock += Time.deltaTime;
		if (Input.IsDown(KeyCode.Mouse0) && reloadClock > reloadTime)
		{
			reloadClock = 0.0;
			var originX = transform.position.x;
			var originY= transform.position.y;
			var direction = transform.rotation.euler.z;
			var colliders = Physics.Raycast(originX, originY, direction);
			trace("hit "+colliders.length+" !");
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}