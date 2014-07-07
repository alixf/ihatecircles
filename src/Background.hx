package;

import haxor.component.Behaviour;
import haxor.core.IRenderable;
import haxor.core.Engine;
import haxor.core.Entity;
import js.html.CanvasRenderingContext2D;

class Background extends Behaviour implements IRenderable
{
	private var clock = new Clock();
	public var canvas : CanvasRenderingContext2D;
	public var size = 25;

	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}
	
	public function OnRender()
	{
		trace("ok");
		if (!entity.destroyed)
		{	
			for(y in 0...Math.ceil(600/size))
			{
				for(x in 0...Math.ceil(800/size))
				{
					var v = Math.round(25 + Math.sin(clock.getTime() * 10 + x + y) * 3 + Math.sin(clock.getTime() * 5 + x - y) * 3);
					var rgb = v + (v << 8) + (v << 16);
					canvas.fillStyle = "#" + StringTools.hex(rgb, 6);
					canvas.fillRect(x*size,y*size,size,size); 
				}
			}
		}
	}
}