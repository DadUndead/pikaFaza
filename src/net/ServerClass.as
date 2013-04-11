package net
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.ServerSocket;
	import flash.net.Socket;

	public class ServerClass extends EventDispatcher
	{	
		public static const STARTED:String = "STARTED";
		public static const FAILED:String = "FAILED";
		public static const CLIENT_CONNECTED:String="CLIENT_CONNECTED";
		public static const CLIENT_DATA:String="CLIENT_DATA";
		public static const CLIENT_DISCONNECT:String="CLIENT_DISCONNECT";
		public static const IO_ERROR:String="IO_ERROR"; 
		public static const CLOSE:String="CLOSE";
		
		private var currentIP:String;
		private var currentPort:uint;
		private var serverSocket:ServerSocket; 
		private var clientSockets:Vector.<Socket> = new Vector.<Socket>(); 
		
		public function ServerClass(currentIP:String, currentPort:uint=1637)
		{
			trace("System support for server: "+ ServerSocket.isSupported);	
			this.currentIP = currentIP;
			this.currentPort = currentPort;
		} 
		
		public function start():void{
			if (ServerSocket.isSupported){
				try 
				{ 
					// Create the server socket 
					serverSocket = new ServerSocket(); 
					
					// Add the event listener 
					serverSocket.addEventListener( Event.CONNECT, connectHandler ); 
					serverSocket.addEventListener( Event.CLOSE, onClose ); 
					
					// Bind to local port
					serverSocket.bind(this.currentPort, this.currentIP); 
					
					// Listen for connections 
					serverSocket.listen(); 
					trace( "Listening on " + serverSocket.localPort ); 
					this.dispatchEvent(new DataEvent(STARTED, false,false, currentIP+":"+currentPort));
				} 
				catch(e:Error) 
				{ 
					trace(e); 
					this.dispatchEvent(new DataEvent(FAILED, false,false,e.toString()));
				} 
			}else{
				trace("Данная система не поддерживает создание сервера");
				this.dispatchEvent(new DataEvent(FAILED, false,false,"Данная система не поддерживает создание сервера"));
			}
		}
		
		public function stop():void{
			trace( "Stop listening on " + serverSocket.localPort );
			for (var i:uint=0; i<clientSockets.length; i++){
				if (clientSockets[i]!=null){
					removeSocketByID(i);
				}
			}
			serverSocket.close(); 
		}
		
		public function sendGlobalMessage(message:String):void{
			trace("Server sendMessage -> "+ message );
			for (var i:uint=0; i<clientSockets.length; i++){
				clientSockets[i].writeUTFBytes(message+"@$" );
				clientSockets[i].flush();
			}
		}
		
		public function sendPrivateMessage(socketID:uint, message:String):void{
			if (socketID<this.numClients){
				trace("Server sendMessage -> "+ message+" to "+socketID );
				clientSockets[socketID].writeUTFBytes(message+"@$");
				clientSockets[socketID].flush();
			}
		}
		
		public function getSocketID(socket:Socket):Number{
			
			for (var i:uint=0; i<clientSockets.length; i++){
				if (clientSockets[i]==socket){
					return i;
				}
			}
			return -1;
		}
		
		public function getSocketByID(socketID:uint):Socket{
			return this.clientSockets[socketID];
		}
		
		public function removeSocketByID(socketID:uint):void{
			var socket:Socket = clientSockets[socketID];
			
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, socketDataHandler); 
			socket.removeEventListener( Event.CLOSE, onClientClose ); 
			socket.removeEventListener( IOErrorEvent.IO_ERROR, onIOError ); 
			
			clientSockets.splice(socketID,1);
		}
		
		private function connectHandler(event:ServerSocketConnectEvent):void 
		{ 
			//The socket is provided by the event object 
			var socket:Socket = event.socket as Socket; 
			clientSockets.push( socket ); 
			socket.addEventListener( ProgressEvent.SOCKET_DATA, socketDataHandler); 
			socket.addEventListener( Event.CLOSE, onClientClose ); 
			socket.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			
			this.dispatchEvent(new DataEvent(CLIENT_CONNECTED, false,false, String(getSocketID(socket))));
		} 
		
		
		private function socketDataHandler(event:ProgressEvent):void 
		{ 
			var socket:Socket = event.target as Socket 	
			//Read the message from the socket 
			var message:String = socket.readUTFBytes( socket.bytesAvailable ); 
			trace( "Received: " + message);
			this.dispatchEvent(new DataEvent(CLIENT_DATA, false,false, getSocketID(socket)+":"+message));
		} 
		
		private function onClientClose( event:Event ):void 
		{ 
			trace( "Connection to client closed." ); 
			//Should also remove from clientSockets array... 
			var socket:Socket = event.target as Socket 
			var socketID:Number=getSocketID(socket);
			this.dispatchEvent(new DataEvent(CLIENT_DISCONNECT, false,false, String(socketID)));
			
			removeSocketByID(socketID);
		} 
		
		private function onIOError( errorEvent:IOErrorEvent ):void 
		{ 
			trace( "IOError: " + errorEvent.text ); 
			this.dispatchEvent(new DataEvent(IO_ERROR, false,false, "IOError: " + errorEvent.text));
		} 
		
		private function onClose( event:Event ):void 
		{ 
			trace( "Server socket closed by OS." ); 
			this.dispatchEvent(new DataEvent(CLOSE, false,false, "Server socket closed by OS."));
		} 
		
		//GET&SET Methods
		public function get numClients():uint{
			return this.clientSockets.length;
		}
		
		
	}
}