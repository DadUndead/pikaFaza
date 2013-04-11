package net
{
	import app.AppStatics;
	
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class ServerParser extends EventDispatcher
	{		
		public static const STARTED:String = "STARTED";
		public static const CLIENT_CONNECTED:String="CLIENT_CONNECTED";
		public static const CLIENT_DATA:String="CLIENT_DATA";
		public static const CLIENT_DISCONNECT:String="CLIENT_DISCONNECT";
		public static const ERROR:String="ERROR"; 
		public static const CLOSE:String="CLOSE";
		
		private var _server:ServerClass;
		private var currentIP:String;
		private var currentPort:uint;
		private var clients:Vector.<UserObject> = new Vector.<UserObject>();
		
		public function ServerParser(currentIP:String, currentPort:uint=1637)
		{
			this.currentIP = currentIP;
			this.currentPort = currentPort;
		}
		
		public function start():void{
			trace("ServerParset "+currentIP+":"+currentPort);
			this._server = new ServerClass(currentIP, currentPort);
			
			this._server.addEventListener(ServerClass.STARTED, onServerStarted );
			this._server.addEventListener(ServerClass.CLOSE, onServerClosed );
			
			this._server.addEventListener(ServerClass.CLIENT_CONNECTED, onClientConnected );
			this._server.addEventListener(ServerClass.CLIENT_DISCONNECT, onClientDisconnected );
			
			this._server.addEventListener(ServerClass.CLIENT_DATA, onClientData );
			
			this._server.addEventListener(ServerClass.FAILED, onError );
			this._server.addEventListener(ServerClass.IO_ERROR, onError );
			
			this._server.start();
		}
		
		public function stop():void{
			this._server.stop();
			
			this._server.removeEventListener(ServerClass.STARTED, onServerStarted );
			this._server.removeEventListener(ServerClass.CLOSE, onServerClosed );
			
			this._server.removeEventListener(ServerClass.CLIENT_CONNECTED, onClientConnected );
			this._server.removeEventListener(ServerClass.CLIENT_DISCONNECT, onClientDisconnected );
			
			this._server.removeEventListener(ServerClass.CLIENT_DATA, onClientData );
			
			this._server.removeEventListener(ServerClass.FAILED, onError );
			this._server.removeEventListener(ServerClass.IO_ERROR, onError );
		}
		
		private function onServerStarted(e:DataEvent):void{
			trace("onServerStarted "+e.data);
			this.dispatchEvent(new DataEvent(STARTED, false,false, e.data));
		}
		
		private function onServerClosed(e:DataEvent):void{
			trace("onServerClosed "+e.data);
		}
		
		private function onClientConnected(e:DataEvent):void{
			trace("onClientConnected "+e.data);
		}
		
		private function onClientDisconnected(e:DataEvent):void{
			trace("onClientDisconnected "+e.data);
			if (clients.length>0){
				trace("Игрок "+clients[uint(e.data)].name+" отключился");
				clients.splice(uint(e.data),1);
			}
		}
		
		private function onClientData(e:DataEvent):void{
			trace("onCliendData "+e.data);
			var arr_data:Array = e.data.split("@$");
			for (var z:uint=0; z< arr_data.length; z++){
				var socketID:uint=arr_data[z].split(":")[0]
				var key:String = arr_data[z].split(":")[1];
				var info:String = arr_data[z].split(":")[2];
				
				switch (key){
					case "connect":
						if (this._server.numClients>2){
							this._server.sendPrivateMessage(socketID, "system:access_denied")
							this._server.removeSocketByID(socketID);
						}else{
							var client:UserObject = new UserObject(); 
							client.name = info;
							client.socket=this._server.getSocketByID(socketID);
							clients.push(client);
							
							this.dispatchEvent(new DataEvent(CLIENT_CONNECTED, false,false, ""));
						}
						if (this._server.numClients==2){
							this._server.sendGlobalMessage("system:access_granted")
							clients[0].enemy = clients[1];
							clients[1].enemy = clients[0];
							
							clients[0].isInGame=false;
							clients[1].isInGame=false;
						}
						break;
					case "disconnect":
						/*clients[socketID].enemy.score++;
						this._server.sendGlobalMessage("score:"+clients[socketID].score+"."+clients[socketID].enemy.score);
						this._server.sendGlobalMessage("chat"+":"+clients[socketID].enemy.name+" "+"напугал врага до смерти!");
						this._server.sendPrivateMessage(this._server.getSocketID(clients[socketID].enemy.socket),"winner:"+clients[socketID].enemy.name);*/
						this._server.sendGlobalMessage("game_over:")
						this._server.stop();
						break;
					case "chat":
						this._server.sendGlobalMessage("chat"+":"+clients[socketID].name+":"+info);
						break;
					case "enemy_name":
						this._server.sendPrivateMessage(socketID,"enemy_name"+":"+clients[socketID].enemy.name);
						break;
					case "turn":
						clients[socketID].turn++;
						
						if (info==clients[socketID].enemy.number){//если угадал
							this._server.sendPrivateMessage(socketID,"user_turn"+":"+info+" p= "+4+" f= "+0);
							this._server.sendPrivateMessage(this._server.getSocketID(clients[socketID].enemy.socket),"enemy_turn"+":"+info+" p= "+4+" f= "+0);
							this._server.sendPrivateMessage(socketID,"complete:");
							clients[socketID].completed = true;
							this._server.sendGlobalMessage("chat"+":"+clients[socketID].name+":"+"отгадал число за "+clients[socketID].turn+" ходов");
							if (clients[socketID].enemy.completed){
								
								if (clients[socketID].turn<clients[socketID].enemy.turn){
									setWinner(clients[socketID]);
								}else{
									setWinner(clients[socketID].enemy);
								}
								
								clients[socketID].isInGame=false;
								clients[socketID].enemy.isInGame=false;
							}
						}else{//если не угадал
							var piks:uint=AppStatics.countPiks(info, clients[socketID].enemy.number);
							var fases:uint=AppStatics.countFases(info, clients[socketID].enemy.number);
							this._server.sendPrivateMessage(socketID,"user_turn"+":"+info+" p= "+piks+" f= "+fases);
							this._server.sendPrivateMessage(this._server.getSocketID(clients[socketID].enemy.socket),"enemy_turn"+":"+info+" p= "+piks+" f= "+fases);
						}
						break;
					case "set_number":
						clients[socketID].number = info;
						
						var fl:Boolean=true;
						for (var i:uint=0; i<clients.length; i++){
							if (clients[i].number==""){
								fl=false;
							}
						}
						if (fl){
							this._server.sendGlobalMessage("ready_go")
							clients[0].isInGame=true;
							clients[1].isInGame=true;
						}
						
						break;
					case "request_new":
						switch (info){
							case "":
								this._server.sendPrivateMessage(this._server.getSocketID(clients[socketID].enemy.socket),"request_new"+":"+"");	
								break;
							case "accept":
								this._server.sendGlobalMessage("request_new"+":"+info);	
								clients[0].init();
								clients[1].init();				
								break;
							case "declined":
								this._server.sendGlobalMessage("request_new"+":"+info);		
								break;
						}					
						break
				}
			}
		}
		
		private function setWinner(win:UserObject):void{
			win.score++;
			this._server.sendPrivateMessage(this._server.getSocketID(win.socket),"score:"+win.score+"."+win.enemy.score);
			this._server.sendPrivateMessage(this._server.getSocketID(win.enemy.socket),"score:"+win.enemy.score+"."+win.score);
			this._server.sendGlobalMessage("chat"+":"+win.name+":"+"победитель!");
			this._server.sendGlobalMessage("winner:"+win.name)
		}
		
		private function onError(e:DataEvent):void{
			trace(e.data);
			this.dispatchEvent(new DataEvent(ERROR, false,false, e.data));
		}
	}
}