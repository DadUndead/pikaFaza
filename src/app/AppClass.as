package
{
	public class AppClass
	{
		public var defaultArr:Vector.<String>;
		public var perfectArr:Vector.<String>;
		public var userArr:Vector.<String>;
		public var zagadka:String;
		
		public function AppClass()
		{
			trace("HELLO");
			defaultArr = generateArray();
			userArr = generateArray();
			
			perfectArr=new Vector.<String>();
			
			for (var i:uint=0; i<defaultArr.length;i++){
				perfectArr.push(defaultArr[i]);
			}
			
			zagadka = perfectArr[Math.round(Math.random()*(perfectArr.length-1))];
			trace("=========================================================================");
			trace("my arr length -> "+defaultArr.length);
			
			var al_arr:Vector.<String> = generateAlexanderArray();
			
			trace("alexander arr length -> "+al_arr.length);
			
			trace("=========================================================================");
			
			//trace("->"+defaultArr);
			//trace(traceArrByQuadColumn(defaultArr));
			var numb:String = makeTurn();
			trace("HELLO0000000000000000000000000000000000\r\n\r\n\r\n Я загадал число ->"+zagadka);

			//trace(traceArrByQuadColumn(defaultArr));
		}
		
		
		public function makeTurn():String{
			/*if (defaultArr.length==1){
				return "Ты загадал "+defaultArr[Math.round(Math.random()*(defaultArr.length-1))];
			}*/
			
			if (defaultArr.length!=0){
				return defaultArr[Math.round(Math.random()*(defaultArr.length-1))];
			}else{
				return "нет такого числа";
			}
		}
		
		public function generateAlexanderArray():Vector.<String>{
			var new_arr:Vector.<String> = new Vector.<String>();
			for(var i:uint=1; i <= 9; i++){
				
				for(var j:uint=0; j <= 9; j++){
					
					if(i!=j){
						
						for(var k:uint=0; k <= 9; k++){
							
							if(k!=j && k!=i){
								
								for(var n:uint=0; n <= 9; n++){
									
									if(n!=j && n!=i && n!=k){
										
										new_arr.push(1000*i+100*j+10*k+n);
										
										//trace(1000*i+100*j+10*k+n);
										//true_numbers_enemy.push(1000*i+100*j+10*k+n);
										//true_numbers_const.push(1000*i+100*j+10*k+n);
									}
								}
							}
						}
					}
				}
			}
			return new_arr;
		}
		
		//генератор массива уникальных цифр от 1234 до 9876
		public function generateArray():Vector.<String>{
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
		
		public function countFaz(param:String):Number{
			var conter:uint=0;
			for (var i:uint=0; i<zagadka.length;i++){
				for (var j:uint=0; j<param.length;j++){
					if (zagadka.charAt(i)==param.charAt(j) ){
						conter++;
					}
				}
			}
			conter-=countPik(param)
			
			return conter;
		}
		public function countPik(param:String):Number{
			var counter:uint=0;
			for (var i:uint=0; i<zagadka.length;i++){
				if (zagadka.charAt(i)==param.charAt(i) ){
					counter++;
				}
			}
			return counter;
		}
		
		public function removeElements(someArr:Vector.<String>, num_check:String, piks:uint, fases:uint):Vector.<String>{
			
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
			
			trace(traceArrByQuadColumn(someArr));
			return someArr;
		}
		
		private function checkPiks(str:String, num_check:String, piks:uint):Boolean{
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
		
		private function checkFase(str:String, num_check:String, fases:uint):Boolean{
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
		public function traceArrByQuadColumn(arr:Vector.<String>):String {
			var _wordMaxLength:uint=4;
			var num_cols:uint=10;
			var raws:uint = Math.ceil(arr.length / num_cols);
			var str:String="\r\n";
			str+="-осталось <"+arr.length+"> вариантов";
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