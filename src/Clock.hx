class Clock
{
    private var lastTime : Float;
	private var factor : Float;
	private var elapsedTime : Float;
	private var run : Bool;
 
	public function new(factor : Float = 1.0)
	{
		this.factor = factor;
		run = true;
		reset();
	}
 
	public function start()
	{
		run = true;
	}
 
	public function stop()
	{
		run = false;
		reset();
	}
 
	public function reset()
	{
		lastTime = haxe.Timer.stamp();
		elapsedTime = 0;
	}
 
	public function pause()
	{
		run = false;
	}
 
	public function getFactor()
	{
		return factor;
	}
 
	public function setFactor(factor : Float)
	{
		getTime();
		this.factor = factor;
	}
 
	public function getTime() : Float
	{
		var time = haxe.Timer.stamp();
		if(run)
			elapsedTime += (time - lastTime) * factor;
		lastTime = time;
		return elapsedTime;
	}
}