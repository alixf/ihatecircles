package;
import haxor.component.Behaviour;
import haxor.core.Entity;
import haxor.core.Engine;
import haxor.math.Quaternion;
import haxor.math.Vector3;
import haxor.core.IUpdateable;
import haxor.input.*;
import haxor.core.Time;
import haxor.math.Mathf;
import motion.Actuate;
import physics.*;
import haxor.component.RigidBody.ForceMode;

class Player extends Behaviour implements IUpdateable implements ITriggerable
{
	var speed = 1500;
	public var game : Game;
	private var reloadClock = 0.0;
	public var myId = 0;
	public var control = false;
	public var score = 0;
	public var health = 3;
	public var invincible = false;
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
		
		transform.scale = Vector3.zero;
		Actuate.update(function(x:Float, y:Float, z:Float) { transform.scale = new Vector3(x, y, z); }, 1.0, [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]);
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
			
				var margin = 10;
				var force = rigidbody.velocity.length / 2 / Time.deltaTime;
				var bounds = { left : 0 + margin, top : 0 + margin, right : 800 - margin, bottom : 600 - margin };
				if (transform.position.x < bounds.left) { 	transform.position = new Vector3(bounds.left, transform.position.y, transform.position.z); 		rigidbody.AddForce(Vector3.right.Scale(force), ForceMode.Velocity); 		}
				if(transform.position.y < bounds.top) { 	transform.position = new Vector3(transform.position.x, bounds.top, transform.position.z); 		rigidbody.AddForce(Vector3.up.Scale(force), ForceMode.Velocity); 			}
				if(transform.position.x > bounds.right) { 	transform.position = new Vector3(bounds.right, transform.position.y, transform.position.z); 	rigidbody.AddForce(Vector3.right.inverse.Scale(force), ForceMode.Velocity); }
				if (transform.position.y > bounds.bottom) { transform.position = new Vector3(transform.position.x, bounds.bottom, transform.position.z);	rigidbody.AddForce(Vector3.up.inverse.Scale(force), ForceMode.Velocity);	}
		}
	}
	
	override function OnDestroy()
	{
		Engine.Remove(this);
	}
	
	public function Trigger(c:Collider)
	{
		var enemy : Enemy = c.GetComponent(Enemy);
		if (enemy != null)
		{
			//Network.instance.hitPlayer(myId, enemy.myId);
			rigidbody.AddForce(transform.position.Sub(enemy.transform.position).normalized.Scale(500 / Time.deltaTime), ForceMode.Velocity);
			
			if (!invincible)
			{
				invincible = true;				
				var ir = GetComponent(ImageRenderer);
				if(ir != null)
					Actuate.tween(ir, 1.0, { opacity : 0.33 } ).onComplete(function() { invincible = false; Actuate.apply(ir, { opacity : 1 } ); } );
			}
		}
	}
}