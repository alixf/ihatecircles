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
			canvas.drawImage(image, -image.naturalWidth / 2 * transform.scale.x, -image.naturalHeight / 2 * transform.scale.y, transform.scale.x * image.naturalWidth, transform.scale.y * image.naturalHeight);
			canvas.restore();
		}
	}
	
	override function OnDestroy():Void
	{
		Engine.Remove(this);
	}
}