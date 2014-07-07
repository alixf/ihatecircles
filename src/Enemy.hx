package;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.*;
import openfl.events.*;
import openfl.geom.*;
import motion.Actuate;

class Enemy extends Sprite
{
	var game : Game;
	var display = new Bitmap(Assets.getBitmapData("assets/enemy.png"));
	var speed = 5.0;

	public function new(game : Game)
	{
		super();
		this.game = game;
		display.x = -display.width/2;
		display.y = -display.height/2;
		addChild(display);

		Actuate.apply(this, {scaleX : 0, scaleY : 0});
		Actuate.tween(this, 0.5, {scaleX : 1, scaleY : 1});

		var t = new ColorTransform();
		t.color = 0xFF0000;
		this.transform.colorTransform = t;
	}

	public function update(event : Event)
	{
		// var velocity = new Point((moveLeft ? -1.0 : 0.0) + (moveRight ? 1.0 : 0.0), (moveUp ? -1.0 : 0.0) + (moveDown ? 1.0 : 0.0));
		// velocity.normalize(speed);
		// x += velocity.x;
		// y += velocity.y;
	}
}