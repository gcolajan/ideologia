require 'json'

$FONDS_INITIAUX = 2500 # Argent au début de la partie
$ARGENT_CASE_DEPART = 1600 # Argent au passage sur la case départ
$TEMPS_JEU = 300 # Temps d'une partie (en secondes)

$INTERVALLE_PING = 30 # Temps entre deux ping envoyés au client (en secondes)
$REPONSE_PING = 10 # Temps maximal pour le client pour répondre au ping (en secondes)

def tojson(type, contenu, delaiReponse=-1)
	return JSON.generate({
		"type" => type,
		"data" => contenu,
		"delay" => delaiReponse
	})
end
