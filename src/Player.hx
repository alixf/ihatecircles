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
	private var reloadClock = new Clock();
	
	public function new(entity : Entity)
	{
		super(entity);
		Engine.Add(this);
		//this.game = game;
		//display.x = -display.width/2;
		//display.y = -display.height/2;
		//addChild(display);
//
		//Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		//Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		//Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
//
		//Actuate.tween(this, 0.5, {scaleX : 1.1, scaleY : 1.1}).ease(motion.easing.Linear.easeNone).repeat().reverse().ease(motion.easing.Linear.easeNone);
	}

	//public function keyDown(event : KeyboardEvent)
	//{
		//switch(event.keyCode)
		//{
			//case 90 : moveUp = true;
			//case 81 : moveLeft = true;
			//case 83 : moveDown = true;
			//case 68 : moveRight = true;
		//}
	//}
//
	//public function keyUp(event : KeyboardEvent)
	//{
		//switch(event.keyCode)
		//{
			//case 90 : moveUp = false;
			//case 81 : moveLeft = false;
			//case 83 : moveDown = false;
			//case 68 : moveRight = false;
		//}
	//}

	//public function mouseDown(evnet : MouseEvent)
	//{
		////shoot = true;
	//}
//
	//public function mouseUp(evnet : MouseEvent)
	//{
		////shoot = false;
	//}

	public function OnUpdate():Void
	{
		
		//var velocity = new Point((moveLeft ? -1.0 : 0.0) + (moveRight ? 1.0 : 0.0), (moveUp ? -1.0 : 0.0) + (moveDown ? 1.0 : 0.0));
		//velocity.normalize(speed);
		//x += velocity.x;
		//y += velocity.y;
//spot
		//if(x < display.width/2) x = display.width/2;
		//if(y < display.height/2) y = display.height/2;
		//if(x > Lib.current.stage.stageWidth - display.width/2) x = Lib.current.stage.stageWidth - display.width/2;
		//if(y > Lib.current.stage.stageHeight - display.height/2) y = Lib.current.stage.stageHeight - display.height/2;
//
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
//
		if (Input.IsDown(KeyCode.Mouse0) && reloadClock.getTime() > 0.125)
		{
			reloadClock.reset();
			Network.instance.addBullet(transform.position.x, transform.position.y, Math.cos(transform.rotation.euler.z) * 1000, Math.sin(transform.rotation.euler.z) * 1000);
		}
	}
}