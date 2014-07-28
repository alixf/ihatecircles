package render;

import haxor.component.Component;
import haxor.core.Entity;
import haxor.core.IDisposable;
import haxor.core.IRenderable;
import haxor.core.Engine;
import js.html.CanvasRenderingContext2D;
import js.html.Image;

class LineRenderer extends Component implements IRenderable
{
	public var canvas : CanvasRenderingContext2D;
	public var opacity = 1.0;
	public var start = { x : 0.0, y : 0.0 };
	public var end = { x : 0.0, y : 0.0 };
	public var style = "#FFFFFF";
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}
	
	public function OnRender()
	{
		if (!entity.destroyed)
		{
			canvas.save();
			canvas.globalAlpha = opacity;
			canvas.translate(transform.position.x, transform.position.y);
			canvas.rotate(transform.rotation.euler.z);

			canvas.strokeStyle = style;
			canvas.beginPath();
			canvas.moveTo(start.x, start.y);
			canvas.lineTo(end.x, end.y);
			canvas.stroke();
			
			canvas.restore();
		}
	}
	
	override function OnDestroy():Void
	{
		Engine.Remove(this);
	}
}