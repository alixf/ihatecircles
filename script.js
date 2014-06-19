function main()
{
	var stage = new PIXI.Stage(0xFFFFFF, true);
	stage.setInteractive(true);

	var renderer = PIXI.autoDetectRenderer(800, 600, null, false, true);
	renderer.view.style.display = "block";
	 
	document.body.appendChild(renderer.view);

	var background = new PIXI.Graphics();
	stage.addChild(background);

	var game = new Game(stage);

	requestAnimFrame(update);

	this.created = new Date().getTime();
	this.clock = 0.0;

	function update()
	{
		this.clock = (new Date().getTime() - this.created) / 1000.0;

		background.clear();
		for(x = 0; x < 800/100; x++)
		{
			for(y = 0; y < 600/100; y++)
			{
				var v = Math.round(200 + Math.sin(this.clock * 10 + x + y) * 3 + Math.sin(this.clock * 5 + x - y) * 3);
				var rgb = v + (v << 8) + (v << 16);
				background.beginFill(rgb);
				background.drawRect(x*100,y*100,100,100);
				background.endFill();
			}
		}

 		game.update();
 		renderer.render(stage);
	    requestAnimFrame(update);
	}
};
window.onload = main;

function Game(stage)
{
	this.stage = stage;

	// Objects
	this.bullets = [];
	this.heroes = [new Hero(this)];
	this.enemies = [];

	// Time
	this.created = new Date().getTime();
	this.clock = 0.0;
	this.deltaTime = 0.0;

	// Input
	this.keyboard =
	{
		_pressed: {},
		isDown: function(keyCode) { return this._pressed[keyCode]; },
		onKeydown: function(event) { this._pressed[event.keyCode] = true;},
		onKeyup: function(event) { delete this._pressed[event.keyCode]; }
	};
	window.addEventListener('keyup', function(keyboard) { return function(event) { keyboard.onKeyup(event); } }(this.keyboard), false);
	window.addEventListener('keydown', function(keyboard) { return function(event) { keyboard.onKeydown(event); } }(this.keyboard), false);

	this.click = function()
	{
		for(i = 0; i < this.heroes.length; ++i)
			if(this.heroes[i].click)
				this.heroes[i].click();
		for(i = 0; i < this.bullets.length; ++i)
			if(this.bullets[i].click)
				this.bullets[i].click();
	}
	stage.click = stage.tap = function(game) { return function(event) { game.click(); } }(this);
	this.mousedown = function()
	{
		for(i = 0; i < this.heroes.length; ++i)
			if(this.heroes[i].mousedown)
				this.heroes[i].mousedown();
		for(i = 0; i < this.bullets.length; ++i)
			if(this.bullets[i].mousedown)
				this.bullets[i].mousedown();
	}
	stage.mousedown = stage.tap = function(game) { return function(event) { game.mousedown(); } }(this);
	this.mouseup = function()
	{
		for(i = 0; i < this.heroes.length; ++i)
			if(this.heroes[i].mouseup)
				this.heroes[i].mouseup();
		for(i = 0; i < this.bullets.length; ++i)
			if(this.bullets[i].mouseup)
				this.bullets[i].mouseup();
	}
	stage.mouseup = stage.tap = function(game) { return function(event) { game.mouseup(); } }(this);

	this.update = function()
	{
		TWEEN.update();
		var newClock = (new Date().getTime() - this.created) / 1000.0;
		this.deltaTime = newClock - this.clock;
		this.clock = newClock;

		for(i = 0; i < this.heroes.length; ++i)
			if(this.heroes[i].update)
				this.heroes[i].update();
		for(i = 0; i < this.bullets.length; ++i)
			if(this.bullets[i].update)
				this.bullets[i].update();
		for(i = 0; i < this.enemies.length; ++i)
			if(this.enemies[i].update)
				this.enemies[i].update();
		
		function shuffle(o)
		{
		    for(var j, x, i = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
		    return o;
		};
		if(this.clock > 1)
		{
			var enemy = new Enemy(this);
			enemy.x = 100 + Math.random() * 600;
			enemy.y = 100 + Math.random() * 400;
			enemy.color = shuffle([0xFC4DC0, 0x218BFF, 0x00A607, 0xFF7813])[0];

			
			var size = {size : 0};
			var target = {size : 20};
			var tween = new TWEEN.Tween(size).to(target, 250).onUpdate(function(){enemy.radius = size.size;}).start();

			this.enemies.push(enemy);
			this.created = new Date().getTime();
		}

		function overlap(a, b)
		{
			return Math.sqrt((b.x-a.x)*(b.x-a.x)+(b.y-a.y)*(b.y-a.y)) < a.radius+b.radius;
		}

		for(i = 0; i < this.enemies.length; ++i)
		{
			for(j = 0; j < this.bullets.length; ++j)
			{
				if(this.enemies[i] && this.bullets[j] && overlap(this.enemies[i].getCollider(), this.bullets[j].getCollider()))
				{
					this.enemies[i].collide(this.bullets[j]);
					this.bullets[j].collide(this.enemies[i]);
				}
			}
		}
	}
}

function Hero(game)
{
	this.game = game;
	this.x = 0;
	this.y = 0;
	this.radius = 10;
	this.graphics = new PIXI.Graphics();
	this.color = 0x218BFF;
	this.velocity = {x : 0, y : 0};
	this.speed = 250;

	this.canShoot = false;

	this.created = new Date().getTime();
	this.clock = 0.0;
	this.deltaTime = 0.0;

	this.cdCreated = new Date().getTime();
	this.cdClock = 0.0;
	this.shootingSpeed = 10;

	game.stage.addChild(this.graphics);

	this.update = function()
	{
		// Compute time
		var newClock = (new Date().getTime() - this.created) / 1000.0;
		this.deltaTime = newClock - this.clock;
		this.clock = newClock;
		this.cdClock = (new Date().getTime() - this.cdCreated) / 1000.0;

		// Move
		this.velocity.x = 0;
		this.velocity.y = 0;
		if(this.game.keyboard.isDown(90))
			this.velocity.y -= 1;
		if(this.game.keyboard.isDown(81))
			this.velocity.x -= 1;
		if(this.game.keyboard.isDown(83))
			this.velocity.y += 1;
		if(this.game.keyboard.isDown(68))
			this.velocity.x += 1;
		
		this.applyPhysics();

		if(this.x < this.radius)
			this.x = this.radius;
		if(this.y < this.radius)
			this.y = this.radius;
		if(this.x > 800-this.radius)
			this.x = 800-this.radius;
		if(this.y > 600-this.radius)
			this.y = 600-this.radius;

 		this.radius = 30 + Math.sin(new Date().getTime() / 25) * 1;
 		this.graphics.rotation = -Math.PI / 4 +  Math.atan2(this.game.stage.getMousePosition().y - this.y, this.game.stage.getMousePosition().x - this.x);

 		if(this.canShoot && this.cdClock > 1.0/this.shootingSpeed)
		{
			this.cdCreated = new Date().getTime();
 			this.shoot();
 		}

 		// Render
 		this.graphics.x = this.x;
 		this.graphics.y = this.y;
		this.graphics.clear();
		this.graphics.lineStyle(10, this.color, 1);
		this.graphics.drawRect(-this.radius/2,-this.radius/2,this.radius,this.radius);
		this.graphics.lineStyle(10, 0x0040E0, 1);
		this.graphics.drawRect(0,0,this.radius/2,this.radius/2);
	}

	this.applyPhysics = function()
	{
		var magnitude = Math.sqrt(this.velocity.x*this.velocity.x+this.velocity.y*this.velocity.y);
		if(this.velocity.x*this.velocity.x+this.velocity.y*this.velocity.y > 1)
		{
			this.velocity.x /= magnitude;
			this.velocity.y /= magnitude;
		}

		this.x += this.velocity.x * this.deltaTime * this.speed * (this.canShoot ? 0.5 : 1);
		this.y += this.velocity.y * this.deltaTime * this.speed * (this.canShoot ? 0.5 : 1);
	}

	this.mousedown = function()
	{
		this.canShoot = true;
	}
	this.mouseup = function()
	{
		this.canShoot = false;
	}

	this.shoot = function()
	{
		var angle = Math.atan2(this.game.stage.getMousePosition().y - this.y, this.game.stage.getMousePosition().x - this.x) + (Math.random()*2-1) * Math.PI / 100;
		var speed = 750;
		var velocity = 
		{
			x : Math.cos(angle),
			y : Math.sin(angle)
		}

		var bullet = new Bullet(this.game);
		bullet.x = this.x + Math.cos(angle) * this.radius/2;
		bullet.y = this.y + Math.sin(angle) * this.radius/2;
		bullet.velocity = velocity;
		bullet.color = this.color;
		bullet.speed = speed;
		this.game.bullets.push(bullet);
	}
}

function Bullet(game)
{
	this.game = game;
	this.x = 0;
	this.y = 0;
	this.size = 4;

	this.graphics = new PIXI.Graphics();
	this.color = 0x666666;
	this.velocity = {x : 0, y : 0};
	this.speed = 250;

	this.created = new Date().getTime();
	this.clock = 0.0;
	this.deltaTime = 0.0;

	game.stage.addChild(this.graphics);

	this.update = function()
	{
		// Compute time
		var newClock = (new Date().getTime() - this.created) / 1000.0;
		this.deltaTime = newClock - this.clock;
		this.clock = newClock;

		// Move
		this.applyPhysics();

		this.graphics.rotation = Math.atan2(this.velocity.y, this.velocity.x) + Math.PI/4;

 		// Render
 		this.graphics.x = this.x;
 		this.graphics.y = this.y;
		this.graphics.clear();
		this.graphics.lineStyle(this.size, this.color, 1);
		//this.graphics.drawCircle(0,0,this.size);
		this.graphics.drawRect(-this.size/2,-this.size/2,this.size,this.size);
	}

	this.applyPhysics = function()
	{
		var magnitude = Math.sqrt(this.velocity.x*this.velocity.x+this.velocity.y*this.velocity.y);
		if(this.velocity.x*this.velocity.x+this.velocity.y*this.velocity.y > 1)
		{
			this.velocity.x /= magnitude;
			this.velocity.y /= magnitude;
		}

		this.x += this.velocity.x * this.deltaTime * this.speed;
		this.y += this.velocity.y * this.deltaTime * this.speed;
		if (this.x < -10*this.size ||
			this.y < -10*this.size ||
			this.x > 800+10*this.size ||
			this.y > 600+10*this.size)
			this.destroy();
	}

	this.destroy = function()
	{
		this.game.stage.removeChild(this.graphics);
		var index = this.game.bullets.indexOf(this);
		if (index > -1)
 		   this.game.bullets.splice(index, 1);
	}

	this.click = function(position)
	{
		// var angle = Math.atan2(this.game.stage.getMousePosition().y - this.y, this.game.stage.getMousePosition().x - this.x);
		// var speed = 500;
		// var velocity = 
		// {
		// 	x : cos(angle) * speed,
		// 	y : sin(angle) * speed
		// }

		// this.game.bullets.push(new Bullet(game, x + cos(angle) * this.radius/2, y + sin(angle) * this.radius/2, velocity));
	}

	this.getCollider = function()
	{
		return {x : this.x, y : this.y, radius : this.size};
	}

	this.collide = function(other)
	{
		this.destroy();
	}
}

function Enemy(game)
{
	this.game = game;
	this.x = 50;
	this.y = 50;
	this.radius = 10;
	this.graphics = new PIXI.Graphics();
	this.color = 0x0080FF;
	this.velocity = {x : 0, y : 0};
	this.speed = 250;

	this.created = new Date().getTime();
	this.clock = 0.0;
	this.deltaTime = 0.0;

	game.stage.addChild(this.graphics);

	this.update = function()
	{
		// Compute time
		var newClock = (new Date().getTime() - this.created) / 1000.0;
		this.deltaTime = newClock - this.clock;

		// Move
		this.applyPhysics();

 		// Render
 		this.graphics.x = this.x;
 		this.graphics.y = this.y;
		this.graphics.clear();
		this.graphics.beginFill(this.color, 1);
		this.graphics.drawCircle(0,0,this.radius);
		this.graphics.endFill();

	}

	this.applyPhysics = function()
	{
		var magnitude = Math.sqrt(this.velocity.x*this.velocity.x+this.velocity.y*this.velocity.y);
		if(this.velocity.x*this.velocity.x+this.velocity.y*this.velocity.y > 1)
		{
			this.velocity.x /= magnitude;
			this.velocity.y /= magnitude;
		}
		this.x += this.velocity.x * this.deltaTime * this.speed;
		this.y += this.velocity.y * this.deltaTime * this.speed;
	}

	this.getCollider = function()
	{
		return {x : this.x, y : this.y, radius : this.radius};
	}

	this.collide = function(other)
	{
		if(other.color == this.color)
			this.color = 0x666666;
		else if(this.color == 0x666666)
			this.destroy();
	}

	this.destroy = function()
	{
		this.game.stage.removeChild(this.graphics);
		var index = this.game.enemies.indexOf(this);
		if (index > -1)
 		   this.game.enemies.splice(index, 1);
	}
}