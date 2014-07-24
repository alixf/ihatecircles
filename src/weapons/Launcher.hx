package weapons;

import haxor.core.Engine;
import haxor.core.IUpdateable;
import haxor.core.Entity;
import haxor.component.Behaviour;
import haxor.input.Input;
import haxor.input.KeyCode;
import haxor.core.Time;

class Launcher extends Behaviour implements IUpdateable
{
	public var reloadTime = 0.125;
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
			Network.instance.addBullet(transform.position.x, transform.position.y, Math.cos(transform.rotation.euler.z) * bulletSpeed, Math.sin(transform.rotation.euler.z) * bulletSpeed);
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}