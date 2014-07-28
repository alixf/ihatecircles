package render;

import haxor.component.Component;
import haxor.core.Entity;
import haxor.core.IDisposable;
import haxor.core.IRenderable;
import haxor.core.Engine;
import js.html.CanvasRenderingContext2D;
import js.html.Image;

class TextRenderer extends Component implements IRenderable
{
	public var image : Image;
	public var canvas : CanvasRenderingContext2D;
	public var opacity = 1.0;
	
	private var fontStyle = "12px Arial";
	public var font(default, set) = "Arial";
	public var fontSize(default, set) = 12;
	public var color = "#FFFFFF";
	public var strokeColor = "#000000";
	public var textWidth = 0.0;
	
	public var text(default, set) = "";
	public function set_text(value : String) : String
	{
		this.text = value;
		textWidth = canvas.measureText(text).width;
		return value;
	}
	
	public var fixedRotation = false;
	
	public function set_font(value : String)
	{
		this.font = value;
		fontStyle = "" + fontSize+"px " + fontStyle;
		textWidth = canvas.measureText(text).width;
		return value;
	}
	public function set_fontSize(value : Int)
	{
		this.fontSize = value;
		fontStyle = "" + fontSize+"px " + fontStyle;
		textWidth = canvas.measureText(text).width;
		return value;
	}
	
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
			canvas.translate(transform.position.x - textWidth/2, transform.position.y);
			if(!fixedRotation)
				canvas.rotate(transform.rotation.euler.z);
			canvas.font = fontStyle;
			canvas.miterLimit = 2;
			canvas.strokeStyle = strokeColor;
			canvas.lineWidth = 3;
			canvas.strokeText(text, 0, 0);
			canvas.fillStyle = color;
			canvas.fillText(text, 0, 0);
			canvas.restore();
		}
	}
	
	override function OnDestroy():Void
	{
		Engine.Remove(this);
	}
}