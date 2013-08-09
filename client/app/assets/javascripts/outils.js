// Conversion Hex -> RGB
function hexToR(h) {return parseInt(h.substr(0,2), 16)}
function hexToG(h) {return parseInt(h.substr(2,2), 16)}
function hexToB(h) {return parseInt(h.substr(4,2), 16)}
function decToHex(dec) {
	hex = parseInt(dec,10).toString(16);
	if (hex.length == 1)
		return '0'+hex
	return hex
}

// Accepte une couleur hexadécimale au format RRGGBB
// Retourne une couleur hexadécimale proche au format RRGGBB
function variationCouleur(hexa) { 
	R = hexToR(hexa);
	G = hexToG(hexa);
	B = hexToB(hexa);
	
	HSL = rgbToHsl(R, G, B)
	
	// On modifie très légèrement H
	variationMaxH = 0.08
	variationH = Math.random()*variationMaxH-(variationMaxH/2)
	H = HSL[0]+variationH
	if (H > 1) H = 1-H
	if (H < 0) H = 1+H 
		
	// Variation aléatoire de la saturation
	portionValide = 0.65 // petit = saturé
	S = Math.random()*portionValide+(1-portionValide)
	// Variation relative de l'intensité lumineuse
	RGB = hslToRgb(H, S, HSL[2])
	
	R = decToHex(RGB[0])
	G = decToHex(RGB[1])
	B = decToHex(RGB[2])
	
	return 	R+G+B
}


// Retourne l'élément sélectionné dans une liste de bouton radios
function radioSelect(name)
{
    i=0;
    while(true)
    {
        el = document.getElementsByName(name)[i]
        if (el){ // Si name[i] existe
                if (el.checked)
                {
                    return el.value;
                }
            }
        else
            return -1;
        i+=1;
    }
}


function showConsoleTerr(id) {
	// Prévoir d'extraire juste le premier numéro
	// Récupérer le nom réel du territoire
	
	//document.getElementById("case"+terrCases[id.substr(4)]).style.opacity=0
	
	if (document.getElementById(id) || document.getElementById(id+'-1'))
	{
		territoire = /[0-9]{1,}/.exec(id)
		document.getElementById('consoleTerr').innerHTML = territoires[territoire]
	}
	else
		document.getElementById('consoleTerr').innerHTML = "Événément !"
}

function cleanConsoleTerr() {
	document.getElementById('consoleTerr').innerHTML = ""
}

function highlightTerr(territoire) {
	showConsoleTerr('terr'+territoire)
	el = document.getElementById('terr'+territoire)
	if (el)
		el.style.fillOpacity = 0
	else
	{
		j = 0;
		while (1) {
			j++
			el = document.getElementById('terr'+territoire+'-'+j)
			if (!el) break;
			el.style.fillOpacity = 0
		}
	}
}


function highlightTerrOver(territoire) {
	cleanConsoleTerr()
	el = document.getElementById('terr'+territoire)
	if (el)
		el.style.fillOpacity = 1
	else
	{
		j = 0;
		while (1) {
			j++
			el = document.getElementById('terr'+territoire+'-'+j)
			if (!el) break;
			el.style.fillOpacity = 1
		}
	}
}


function fermer(element) {
	if (!listenerActif) element.style.display='none'
}


function chercherTerritoire(pos) {
	found = -1
	for (i = 1 ; i <= nbTerritoires ; i++)
		if (terrCases[i] == pos)
			found = i
	return found		
}

function chercherProprietaire(terr) {
	found = -1
	for (i = 0 ; i < nbJoueurs ; i++)
		for (j = 0 ; j < ep_listeTerritoires[i].length ; j++)
			if (ep_listeTerritoires[i][j] == terr)
				found = i
	return found	
}
