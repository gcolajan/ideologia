var tMin = 0;
var tSec = 0;

function setTimer(minutes, secondes=0) {
	if (tMin == 0 && tSec == -1)
	{
		tMin = minutes
		tSec = secondes
		timer("countdown");
	}
	else
	{
		tMin = minutes
		tSec = secondes
	}


}

function timer(id) {
	interval = setInterval(function() {
		var el = document.getElementById(id);
		el.style.textDecoration='none'
		if(tSec < 0) {
			if(tMin == 0) { //Si les tMin sont égales à 00 et les secondes aussi, alors on met une alerte pour le temps écoulé
				el.innerHTML = "00 : 00";  
				el.style.textDecoration='blink'
				clearInterval(interval);
				return;
			}
			else { //Sinon, on réduit les tMin de 1, et on remet les secondes à 59
				tMin--;
				tSec = 59;
			}
		}
		var min = tMin;
		var sec = tSec;
		if (tMin<=9){ //Si les tMin sont inférieurs ou égales à 9, on fait afficher 09
			min='0'+tMin;
		}
		if (tSec<=9){ //Si les secondes sont inférieurs ou égales à 9, on fait afficher 09
			sec='0'+tSec;
		}
		el.innerHTML = min + ' : ' + sec;
		tSec--;
	}, 1000); // Temps entre chaque seconde (1000 millisecondes)
}
