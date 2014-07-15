import haxor.component.Component;
import haxor.core.Entity;
import haxor.core.IDisposable;
import haxor.core.IRenderable;
import haxor.core.Engine;
import js.html.CanvasRenderingContext2D;
import js.html.Image;

class ImageRenderer extends Component implements IRenderable
{
	public var image : Image;
	public var canvas : CanvasRenderingContext2D;
	public var opacity = 1.0;
	//
	//private var fontStyle = "12px Verdana";
	//public var font(default, set) : String;
	//public function set_font(value : String)
	//{
		//fontStyle = "" + fontSize+"px " + fontStyle;
	//}
	//
	//public var fontSize(default, set) : Int;
	//public function set_fontSize(value : Int)
	//{
		//fontStyle = "" + fontSize+"px " + fontStyle;
	//}
	//
	//public var text(default, set) = "";
	//public functin set_text()
	//{
		//measureText()
	//}
	//
	//public function new(entity : Entity)
	//{
		//super(entity);
		//Engine.Add(this);
	//}
	//
	//public function OnRender()
	//{
		//if (!entity.destroyed)
		//{
			//canvas.save();
			//canvas.globalAlpha = opacity;
			//canvas.translate(transform.position.x, transform.position.y);
			//canvas.rotate(transform.rotation.euler.z);
			//canvas.font = fontStyle;
			//canvas.fillStyle="#FF0000";
			//canvas.fillText(text, 0, 0);
			//
			//canvas.restore();
		//}
	//}
	//
	//override function OnDestroy():Void
	//{
		//Engine.Remove(this);
	//}
}