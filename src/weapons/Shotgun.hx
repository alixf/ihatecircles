package weapons;

import haxor.core.Engine;
import haxor.core.IUpdateable;
import haxor.core.Entity;
import haxor.component.Behaviour;
import haxor.input.Input;
import haxor.input.KeyCode;
import haxor.core.Time;

class Shotgun extends Behaviour implements IUpdateable
{
	public var reloadTime = 1.0;
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
			for (i in 0...5)
			{
				var angle = Math.random() * Math.PI / 5 - Math.PI / 10;
				var speed = 1.0 - Math.random() * 0.33;
				Network.instance.addBullet(transform.position.x, transform.position.y, Math.cos(transform.rotation.euler.z + angle) * bulletSpeed * speed, Math.sin(transform.rotation.euler.z + angle) * bulletSpeed * speed);
			}
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}