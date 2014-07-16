import js.html.Element;
import js.Browser;

class UI
{
	static public var instance(get, null) : UI = null;
	static public function get_instance()
	{
		if (instance == null)
			instance = new UI();
		return instance;
	}
	
	private var element : Element;
	
	private function new()
	{
		element = Browser.document.getElementById("ui");
	}
	
	public function log(content : String)
	{
		element.innerHTML += content;
	}
	
	public function addPlayer(id : Int, name : String)
	{
		var playerElement = Browser.document.getElementById("p" + (id+1));
		playerElement.className = "player";
		cast(playerElement.getElementsByClassName("name")[0],Element).innerHTML = name;
	}
	public function removePlayer(id : Int)
	{
		var playerElement = Browser.document.getElementById("p" + (id+1));
		playerElement.className = "player empty";
		cast(playerElement.getElementsByClassName("score")[0], Element).innerHTML = "0";
		cast(playerElement.getElementsByClassName("name")[0], Element).innerHTML = "Empty Slot";
	}
	public function setPlayerScore(id : Int, score : Float)
	{
		var playerElement = Browser.document.getElementById("p" + (id+1));
		cast(playerElement.getElementsByClassName("score")[0], Element).innerHTML = ""+Std.int(score);
	}
	
	public function setPlayerHealth(id : Int, health : Int)
	{
		var playerElement = Browser.document.getElementById("p" + (id+1));
		var hps = playerElement.getElementsByClassName("hp");
		var i = 0;
		for (hp in hps)
			cast(hp, Element).className = i++ < health ? "hp" : "hp down";
	}
}