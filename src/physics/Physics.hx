package physics;

import haxor.component.Component;
import haxor.math.Vector3;

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
	
	public static function Raycast(x : Float, y : Float, angle : Float, ?distance : Float = 2000)
	{
		var x0 = x;
		var y0 = y;
		var x1 = x + Math.cos(angle) * distance;
		var y1 = y + Math.sin(angle) * distance;
		
		var m = (y1 - y0) / (x1 - x0);
		var b = y0 - (m * x0);
	 
		var collidersHit = new Array<Collider>();
		for (collider in colliders)
		{
			if (collider.GetComponent(Enemy))
			{
			var center = collider.center;
			var radius = collider.radius;
			
			var px = (m * center.y + center.x - m * b) / (m * m + 1);
			var py = (m * m * center.y + m * center.x + b) / (m * m + 1);
			
			collider.entity.transform.position = new Vector3(px, py, 0.0);
			
			var distance = Math.sqrt((center.x - px) * (center.x - px) + (center.y - py) * (center.y - py));
			if (distance <= radius)
				collidersHit.push(collider);	
			}
		}
		
		return collidersHit;
	}
}