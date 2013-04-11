package net
{
	import flash.net.Socket;

	public class UserObject
	{
		public var name:String="unnamed";
		public var socket:Socket;
		public var score:uint=0;
		private var _number:String="";
		public var enemy:UserObject;
		public var turn:uint=0;
		public var completed:Boolean=false;
		public var isInGame:Boolean=false;
		public var status:String="";
		public var enemy_arr:Vector.<String>;
		
		public function UserObject()
		{
			this.isInGame=false;
			this.score=0;
		}
		
		public function init():void{
			this._number="";
			this.turn=0;
			this.completed=false;
			this.isInGame=false;
			this.status="";
		}
		public function set number(val:String):void{
			if (!isInGame){
				this._number=val;
			}else{
				trace("Ошибка! Нельзя менять число в процессе игры!");
			}
		}
		
		public function get number():String{
			return this._number;
		}
	}
}