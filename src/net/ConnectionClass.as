package net
{	
	import air.net.SocketMonitor;
	
	import app.PlayerInfo;
	
	import flash.errors.IOError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.controls.Alert;

	public class ConnectionClass extends EventDispatcher
	{
		public static const CONNECTION_AVIABLE:String="CONNECTION_AVIABLE";
		public static const SCAN_COMPLETE:String="SCAN_COMPLETE";
		public static const CONNECTED:String="CONNECTED";
		public static const CHAT_MESSAGE:String="CHAT_MESSAGE";
		public static const ACCESS:String="ACCESS";
		public static const TURN:String="TURN"; 
		public static const READY_GO:String="READY_GO";
		public static const COMPLETE:String="COMPLETE";
		public static const WIN:String="WIN";
		public static const GAME_OVER:String="GAME_OVER";
		public static const REQUEST_NEW:String="REQUEST_NEW";
		
		public var _curMonitors:Vector.<SocketMonitor> = new Vector.<SocketMonitor>(255);
		private var _curSubNet:uint;
		public var _isConnected:String;
		public var _port:uint =1637; //1637
		private var _isRefreshing:Boolean=false;
		
		public var _connectionTiimer:Timer = new Timer(500,1);
		private var netInfo:NetInfoClass = new NetInfoClass();
		
		private var _clientSocket:Socket;
		private var _score:String="0.0";
		
		public function ConnectionClass()
		{
			//scanBroadcasts();
		}
		
		public function checkIP(ip:String):void{
			if (_isRefreshing){
				stopScan();
			}
			
			var tmp_host:String = ip;
			var tmp_monitor:SocketMonitor = new SocketMonitor(tmp_host, this._port);
			
			tmp_monitor.start();
			
			tmp_monitor.addEventListener(StatusEvent.STATUS, onSocketStatus);
			this._connectionTiimer.addEventListener(TimerEvent.TIMER_COMPLETE, onConnectionTimerComplete);
			this._connectionTiimer.start();
		}
		
		private function scanBroadcasts():void{
			var subNets:Vector.<String> = netInfo.subnets;
			netInfo.getNetworkInterfaces();
			
			trace("current subNets -> "+subNets);
			for (var i:uint=0; i<subNets.length; i++){
				for (var j:uint=0; j<255; j++){
					var tmp_host:String = subNets[i]+"."+j;
					var tmp_monitor:SocketMonitor = new SocketMonitor(tmp_host, this._port);
					this._curMonitors[j] =tmp_monitor;
					
					tmp_monitor.start();
					
					tmp_monitor.addEventListener(StatusEvent.STATUS, onSocketStatus);
				}
			}
			
			this._connectionTiimer.addEventListener(TimerEvent.TIMER_COMPLETE, onConnectionTimerComplete);
			this._connectionTiimer.start();
		}
		
		private function onConnectionTimerComplete(e:TimerEvent):void{
			trace( "Connection failed by timeOut" );
			this._connectionTiimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onConnectionTimerComplete);
			this._connectionTiimer.reset();
			this._connectionTiimer.stop();
			
			
			this.dispatchEvent(new DataEvent(SCAN_COMPLETE,false,false,""));
			stopScan();
		}
		
		public function refresh():void{
			this._isRefreshing=true;
			scanBroadcasts();
			trace("scanning has been started");
		}
		
		public function stopScan():void{
			this._isRefreshing=false;
			stopMonitors();
			
			this._connectionTiimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onConnectionTimerComplete);
			this._connectionTiimer.reset();
			trace("scanning has been stopped");
		}
		
		private function stopMonitors():void{
			trace("stop monitors");
			for (var i:uint=0; i< this._curMonitors.length; i++){
				if (this._curMonitors[i]!=null){
					this._curMonitors[i].stop();
					this._curMonitors[i].removeEventListener(StatusEvent.STATUS, onSocketStatus);
					this._curMonitors[i]=null;
				}
			}
		}
		
		public function get isRefreshing():Boolean{
			return this._isRefreshing;
		}
		
		private function onSocketStatus(e:StatusEvent):void
		{
			
			var monitor:SocketMonitor = e.target as SocketMonitor;
			isConnected = monitor.available.toString();
			
			monitor.removeEventListener(StatusEvent.STATUS,onSocketStatus);
			
			//trace("status ===>"+monitor.host+":"+monitor.port+" is "+e.code+" | ping = "+this._connectionTiimer.currentCount);
			
			if (monitor.available)
			{
				trace("Connection to"+monitor.host+":"+monitor.port+" is aviable");
				this.dispatchEvent(new DataEvent(CONNECTION_AVIABLE,false,false,monitor.host+":"+monitor.port));
				
			} else {
				//Alert.show( "Connection to "+this._host+":"+this._port+" NOT established !" );
			}
			monitor.stop();
		}
		
		public function connectTo(ip:String, port:uint):void{
			this._clientSocket = new Socket(ip, port);
			this._clientSocket.addEventListener(Event.CONNECT, onSocketConnectHandler);
			
		}
		
		private function onSocketData(e:ProgressEvent):void{
			//trace("Вам говорят: \r\n --->"+this._socket.readUTFBytes(this._socket.bytesAvailable)+ "<--- \r\n");
			var arr_data:Array = this._clientSocket.readUTFBytes(this._clientSocket.bytesAvailable).toString().split("@$");
			for (var i:uint=0; i< arr_data.length; i++){
				var received_data:String = arr_data[i];
				var key:String = received_data.split(":")[0];
				var info:String = received_data.split(":")[1];
				var tail:String = received_data.split(":")[2];
				
				trace("Вам говорят: \r\n --->"+received_data+ "<--- \r\n");
				
				switch (key){
					case "system":
						switch (info){
							case "access_granted":
								this.sendMessage("enemy_name","");
								this.isConnected="true";
								break;
							case "access_denied":
								this.dispatchEvent(new DataEvent(ACCESS, false,false, "false"));
								this.isConnected="false";
								break;
						}
						break;
					case "game_over":
						this.dispatchEvent(new DataEvent(GAME_OVER, false,false, ""));
						this.isConnected="false";
						break;
					case "ready_go":
						this.dispatchEvent(new DataEvent(READY_GO, false,false, ""));
						break;
					case "chat":
						this.dispatchEvent(new DataEvent(CHAT_MESSAGE, false,false, info+": "+tail));
						break;
					case "enemy_name":
						PlayerInfo.enemyName = info;
						this.dispatchEvent(new DataEvent(ACCESS, false,false, "true"));
						break;
					case "user_turn":
						this.dispatchEvent(new DataEvent(TURN, false,false, "user:"+info));
						break;
					case "enemy_turn":
						this.dispatchEvent(new DataEvent(TURN, false,false, "enemy:"+info));
						break;
					case "complete":
						this.dispatchEvent(new DataEvent(COMPLETE, false,false, ""));
						break;
					case "winner":
						this.dispatchEvent(new DataEvent(WIN, false,false, info));
						break;
					case "score":
						this._score = info;
						break;
					case "request_new":
						this.dispatchEvent(new DataEvent(REQUEST_NEW, false,false, info));						
						break;
				}
			}
		}
		
		private function sendMessage(api:String, message:String):void{
			trace("Client sendMessage ->"+api+":"+message);
			if (this._clientSocket!=null){
				this._clientSocket.writeUTFBytes(api+":"+message+"@$");
				this._clientSocket.flush(); 
			}
		}
		
		public function requestNewGame():void{
			sendMessage("request_new","");
		}
		
		public function acceptNewGameRequest(flag:Boolean):void{
			if (flag){
				sendMessage("request_new","accept");
			}else{
				sendMessage("request_new","declined");				
			}
		}
		
		public function setNumber(val:String):void{
			sendMessage("set_number", val);
		}
		public function setTurn(val:String):void{
			sendMessage("turn", val);
		}
		public function setChat(val:String):void{
			sendMessage("chat", val);
		}
		public function tryToConnect(val:String):void{
			sendMessage("connect", val);
		}
		
		public function stop():void{
			sendMessage("disconnect","");
		}
		
		public function get score():String{
			return this._score;
		}
		
		private function onSocketConnectHandler(e:Event):void{
			trace("Client connected to --->"+this._clientSocket.remoteAddress+ ":"+this._clientSocket.remotePort);
			
			this.dispatchEvent(new DataEvent(CONNECTED, false,false, this._clientSocket.remoteAddress+ ":"+this._clientSocket.remotePort));
			
			this._clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		}
		
		//--------------------------
		public function get isConnected():String
		{
			return _isConnected;
		}
		
		[Bindable]
		public function set isConnected(_isConnected:String):void
		{
			this._isConnected = _isConnected; 
		}
	}
}