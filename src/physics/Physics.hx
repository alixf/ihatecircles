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
	
	public static function hit(line : {x : Float, y : Float, angle : Float}, circle : {x : Float, y : Float, radius : Float})
	{
		var angle2 = Math.atan2(circle.y - line.y, circle.x - line.x);
		var diff = angleDiff(angle2, line.angle);
		var distance = Math.sqrt((circle.x - line.x) * (circle.x - line.x) + (circle.y - line.y) * (circle.y - line.y));
		var distanceToLine = Math.abs(diff * distance);
		return distanceToLine <= circle.radius / Math.PI;
	}
	
	public static function Raycast(x : Float, y : Float, angle : Float)
	{
		var collidersHit = new Array<Collider>();
		for (collider in colliders)
		{
			if (collider.GetComponent(Enemy))
			{
				var line = { x : x, y : y, angle : angle };
				var circle = { x : collider.transform.position.x, y : collider.transform.position.y, radius : collider.radius };
				if (hit(line, circle))
					collidersHit.push(collider);	
			}
		}
		
		return collidersHit;
	}
	
	public static function angleDiff(a : Float, b : Float)
	{
		return mod((a + Math.PI -  b), 2*Math.PI) - Math.PI;
	}
	
	public static function mod(a : Float, b : Float)
	{
		while (a >= b)
			a -= b;
		while (a < 0.0)
			a += b;
		return a;
	}
}