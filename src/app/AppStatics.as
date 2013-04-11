package app
{
	public class AppStatics
	{
		
		public static function countPiks(num1:String, num2:String):uint{
			var counter:uint=0;
			
			for (var i:uint=0; i< num1.length; i++){
				for (var j:uint=i; j< num1.length; j++){
					if (j==i &&num1.charAt(i)==num2.charAt(j)){
						counter++;
						break;
					}
				}
			}
			return counter;
		}
		
		public static function countFases(num1:String, num2:String):uint{
			var counter:uint=0;
			for (var i:uint=0; i< num1.length; i++){
				for (var j:uint=0; j< num1.length; j++){
					if (j!=i &&num1.charAt(i)==num2.charAt(j)){
						counter++;
						break;
					}
				}
			}
			return counter;
		}
	}
}