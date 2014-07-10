package physics;

import haxor.component.Component;
import haxor.core.Entity;
import haxor.core.ICollidable;
import haxor.core.IDisposable;
import haxor.math.Vector2;

class Collider extends Component
{
	public var radius = 0.0;
	public var center = new Vector2(0.0, 0.0);
	
	public function new(entity : Entity)
	{
		super(entity);
		Physics.Add(this);
	}
	
	override function OnDestroy():Void
	{
		Physics.Remove(this);
	}
}