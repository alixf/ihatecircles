package physics;

import haxor.component.Component;

class Physics
{
	public static var colliders = new Array<Collider>();
	
	public static function Add(collider : Collider)
	{
		colliders.push(collider);
	}
	public static function Remove(collider : Collider)
	{
		colliders.remove(collider);
	}
	public static function Update()
	{
		for (i in 0...colliders.length)
		{
			var c1 = colliders[i];
			for (j in (i+1)...colliders.length)
			{
				var c2 = colliders[j];
				
				var x1 = c1.center.x + c1.transform.position.x;
				var y1 = c1.center.y + c1.transform.position.y;
				var r1 = c1.radius * (c1.transform.scale.x + c1.transform.scale.y) / 2;
				var x2 = c2.center.x + c2.transform.position.x;
				var y2 = c2.center.y + c2.transform.position.y;
				var r2 = c2.radius * (c2.transform.scale.x + c2.transform.scale.y) / 2;
				var dist = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
				
				if (dist <= (r1 + r2))
				{
					for (component in c1.GetComponents(Component))
					{
						if (Std.is(component, ITriggerable))
						{
							var tmp : ITriggerable = cast component;
							tmp.Trigger(c2);
						}
					}
					
					for (component in c2.GetComponents(Component))
					{
						if (Std.is(component, ITriggerable))
						{
							var tmp : ITriggerable = cast component;
							tmp.Trigger(c1);
						}
					}
				}
			}
		}
	}
}