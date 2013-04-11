package app
{
	public class StaticPF
	{
		public function StaticPF()
		{
		}
		
		public static function getRandomNumber():String{
			var perfectArr:Vector.<String> = getPerfectArray();
			return perfectArr[Math.round(Math.random()*(perfectArr.length-1))];
		}
		
		public static function getRandomInArray(arr:Vector.<String>):String{
			return arr[Math.round(Math.random()*(arr.length-1))];
		}
		public static function getPerfectArray():Vector.<String>{
			var new_arr:Vector.<String>=new Vector.<String>();
			
			for (var i:uint=1023; i<=9876; i++){
				var str_tmp:String = String(i);
				var has_dupl:Boolean = false;
				
				for (var j:uint=0;j<str_tmp.length; j++){	//проходим по длине числа
					
					for (var k:uint=j+1;k<str_tmp.length; k++){ //сравниваем со всеми числами
						if (str_tmp.charAt(j)==str_tmp.charAt(k)){
							has_dupl=true;
							break;
						}
					}
					
					if(has_dupl){
						break;
					}
				}
				
				(!has_dupl)?new_arr.push(str_tmp):null;
				
			}
			return new_arr;
		}
		
		public static function countFaz(number:String, zagadka:String):Number{
			var conter:uint=0;
			for (var i:uint=0; i<zagadka.length;i++){
				for (var j:uint=0; j<number.length;j++){
					if (zagadka.charAt(i)==number.charAt(j) ){
						conter++;
					}
				}
			}
			conter-=countPik(number, zagadka)
			
			return conter;
		}
		public static function countPik(number:String, zagadka:String):Number{
			var counter:uint=0;
			for (var i:uint=0; i<zagadka.length;i++){
				if (zagadka.charAt(i)==number.charAt(i) ){
					counter++;
				}
			}
			return counter;
		}
		
		public static function removeElements(array:Vector.<String>, num_check:String, piks:uint, fases:uint):Vector.<String>{
			var someArr:Vector.<String> = array;
			
			for (var i:uint=0;i<someArr.length; i++){//проходим по массиву чисел
				var p_tmp:uint=0;
				var f_tmp:uint=0;
				var str_tmp:String = someArr[i];
				if (checkFase(str_tmp, num_check, fases+piks)==false){
					someArr.splice(i,1)
					i--;
				}else if (checkPiks(str_tmp, num_check, piks)==false){
					someArr.splice(i,1)
					i--;
				}
			}
			
			return someArr;
		}
		
		private static function checkPiks(str:String, num_check:String, piks:uint):Boolean{
			//сравниваем str с num_check
			//если  столько же цифр стоят на своих местах
			
			var num_tmp:String = String(num_check);
			var counter:uint=0;
			
			for (var i:uint=0; i<str.length;i++){ //проверяем число на соответствие
				if (str.charAt(i) ==num_tmp.charAt(i)){
					counter++;
					if (counter>piks){
						return false;
					}
				}	
			}
			
			if (counter==piks){ 
				return true
			}else{
				return false;
			}
			
			
		}
		
		private static function checkFase(str:String, num_check:String, fases:uint):Boolean{
			//сравниваем str с num_check
			//если совпадает столько цифр сколько фаз в заданном то соответствует
			var num_tmp:String = String(num_check);
			var counter:uint=0;
			
			for (var i:uint=0; i<str.length;i++){ //проверяем число на соответствие
				for (var j:uint=0; j<num_tmp.length;j++){
					if (str.charAt(i) ==num_tmp.charAt(j)){
						counter++;
						if (counter>fases){
							return false;
						}
					}	
				}
			}
			
			if (counter==fases){ 
				return true
			}else{
				return false;
			}
			
		}
		
		//методы вывода#######################################################################
		//выводим массив в 2 колонки
		public static function traceArrByQuadColumn(arr:Vector.<String>):String {
			var _wordMaxLength:uint=4;
			var num_cols:uint=10;
			var raws:uint = Math.ceil(arr.length / num_cols);
			var str:String="\r\n";
			str+="-осталось вариантов <"+arr.length+">";
			for (var i:uint = 0; i <raws; i++) {
				str+="\r\n";
				
				for (var j:uint=0;j<num_cols;j++){ // j - номер столбца 
					if (i+raws*j<arr.length){
						str+=arr[i+raws*j]+"-|-";
					}
				}
				
				//trace(str);
			}
			//	trace("----------------------------------------------------------------------------------------------\r\n");
			str+="\r\n----------------------------------------------------------------------------------------------\r\n"
			return str;
		}
		//####################################################################################
	}
}