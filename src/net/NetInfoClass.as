package net
{
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;

	public class NetInfoClass
	{
		private var _subnets:Vector.<String>;
		
		public function NetInfoClass()
		{
		}
		
		public function get netCollection():Vector.<String>{
			var results:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			var broadcasts:Vector.<String> = new Vector.<String>();
			
			for (var i:int=0; i<results.length; i++){
				for (var j:int=0; j<results[i].addresses.length; j++)
				{
					broadcasts.push(results[i].addresses[j].broadcast);
				}
			}
			return broadcasts;
		}
		
		public function getIPByBroadcast(param:String):String{
			var ip:String;
			
			var results:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			
			for (var i:int=0; i<results.length; i++){
				for (var j:int=0; j<results[i].addresses.length; j++)
				{
					if (results[i].addresses[j].broadcast==param){
						return results[i].addresses[j].address;
					}
				}
			}
			return "undefined";
		}
		
		public function get subnets():Vector.<String>{
			
			var results:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			this._subnets = new Vector.<String>();
			
			for (var i:int=0; i<results.length; i++){
				for (var j:int=0; j<results[i].addresses.length; j++)
				{
					var ip:String=results[i].addresses[j].broadcast;
					if (ip.split(".")[1]!=undefined){
						this._subnets.push(ip.split(".")[0]+"."+ip.split(".")[1]+"."+ip.split(".")[2]);
					}
				}
			}
			
			
			return this._subnets;
		}
		
		public function getNetworkInterfaces():void{			
		var results:Vector.<NetworkInterface> =	NetworkInfo.networkInfo.findInterfaces();
		
		var output:String = "";
		for (var i:int=0; i<results.length; i++)
		{
		output = output
		+ "Name: " + results[i].name + "\n"
		+ "DisplayName: " + results[i].displayName + "\n"
		+ "MTU: " + results[i].mtu + "\n"
		+ "HardwareAddr: " + results[i].hardwareAddress + "\n"
		+ "Active: "  + results[i].active + "\n";
		
		
		for (var j:int=0; j<results[i].addresses.length; j++)
		{
		output = output
		+ "Addr: " + results[i].addresses[j].address + "\n"
		+ "Broadcast: " + results[i].addresses[j].broadcast + "\n"
		+ "PrefixLength: " + results[i].addresses[j].prefixLength + "\n"
		+ "IPVersion: " + results[i].addresses[j].ipVersion + "\n";
		}
		
		output = output + "\n";
		}
		trace("net => \r\n "+output);
		
		}
	}
}