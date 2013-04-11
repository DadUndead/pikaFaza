package app
{
	import flash.events.Event;
	
	public class AnyDataEvent extends Event
	{
		public function AnyDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}

package
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
		//Your Custom Event
		public static const CATEGORY:String = "Category";
		
		//Here I type the data property as an Object, but it could also 
		//be a String , depending on the type of info you need to pass
		public var data:Object;
		
		public function MenuEvent( type:String , data:Object ):void
		{
			super ( type );
			this.data = data;
		}
		
		override public function clone():MenuEvent
		{
			return new MenuEvent( type , data );
		}
		
	}
