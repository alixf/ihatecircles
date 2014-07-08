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
}