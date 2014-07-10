package;
import haxor.component.Behaviour;
import haxor.core.Entity;
import haxor.core.Engine;
import haxor.core.IFixedUpdateable;
import haxor.math.Quaternion;
import haxor.math.Vector3;
import haxor.core.IUpdateable;
import haxor.input.*;
import haxor.core.Time;
import haxor.math.Mathf;

class Player extends Behaviour implements IUpdateable
{
	var speed = 1500;
	public var game : Game;
	private var reloadClock = 0.0;
	public var myId = 0;
	public var control = false;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
	}

	public function OnUpdate():Void
	{		
		if (control)
		{
			reloadClock += Time.deltaTime;
			
			transform.rotation = Quaternion.FromAxisAngle(new Vector3(1, 0, 0), Math.atan2(Input.mouse.y - transform.position.y - game.canvasElement.getBoundingClientRect().top, Input.mouse.x - transform.position.x - game.canvasElement.getBoundingClientRect().left));

			var vx = rigidbody.velocity.x;
			var vy = rigidbody.velocity.y;
			if (Input.IsDown(KeyCode.Q)) { vx += -1 * Time.deltaTime * speed; }		
			if (Input.IsDown(KeyCode.D)) { vx +=  1 * Time.deltaTime * speed; }
			if (Input.IsDown(KeyCode.Z)) { vy += -1 * Time.deltaTime * speed; }
			if (Input.IsDown(KeyCode.S)) { vy +=  1 * Time.deltaTime * speed; }
			vx = Mathf.Lerp(vx, 0.0, Time.deltaTime * 3.0);
			vy = Mathf.Lerp(vy, 0.0, Time.deltaTime * 3.0);
			rigidbody.velocity = new Vector3(vx, vy, 0);
			
			Network.instance.updatePosition(transform.position.x, transform.position.y, transform.rotation.euler.z, rigidbody.velocity.x, rigidbody.velocity.y);

			if (Input.IsDown(KeyCode.Mouse0) && reloadClock > 0.125)
			{
				reloadClock = 0.0;
				Network.instance.addBullet(myId, transform.position.x, transform.position.y, Math.cos(transform.rotation.euler.z) * 1000, Math.sin(transform.rotation.euler.z) * 1000);
			}	
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
}