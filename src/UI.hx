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
	private var players : Array<Element>;
	
	private function new()
	{
		element = Browser.document.getElementById("ui");
		players =
		[
			Browser.document.getElementById("p1"),
			Browser.document.getElementById("p2"),
			Browser.document.getElementById("p3"),
			Browser.document.getElementById("p4")
		];
	}
	
	public function log(content : String)
	{
		element.innerHTML += content;
	}
	
	public function addPlayer(id : Int, name : String)
	{
		var playerElement = Browser.document.getElementById("p" + (id+1));
		players[id].className = "player";
		cast(players[id].getElementsByClassName("name")[0],Element).innerHTML = name;
	}
	public function removePlayer(id : Int)
	{
		players[id].className = "player empty";
		cast(players[id].getElementsByClassName("score")[0], Element).innerHTML = "0";
		cast(players[id].getElementsByClassName("name")[0], Element).innerHTML = "Empty Slot";
	}
	public function setPlayerScore(id : Int, score : Float)
	{
		cast(players[id].getElementsByClassName("score")[0], Element).innerHTML = ""+Std.int(score);
	}
	
	public function setPlayerHealth(id : Int, health : Int)
	{
		var hps = players[id].getElementsByClassName("hp");
		var i = 0;
		for (hp in hps)
			cast(hp, Element).className = i++ < health ? "hp" : "hp down";
	}
}