require 'json'
require 'thread'
require 'mysql'
require 'em-websocket'

$LOAD_PATH << File.dirname(__FILE__) + "/bibliotheques"

require 'Salon'
require 'Partie'
require 'GestionJoueur'
require 'Reception'

$FONDS_INITIAUX = 2500 # Argent au début de la partie
$ARGENT_CASE_DEPART = 1600 # Argent au passage sur la case départ
$TEMPS_JEU = 300 # Temps d'une partie (en secondes)

$INTERVALLE_PING_PARTIE = 30 # Temps entre deux ping envoyés au client (en secondes) lors de la partie
$INTERVALLE_PING_SALON = 2 # Temps entre deux ping envoyés au client (en secondes) lors du salon
$REPONSE_PING = 1 # Temps maximal pour le client pour répondre au ping (en secondes)

# Connexion SQL
$host="localhost"
$user="root"
$mdp=""
$bdd=""

def tojson(type, contenu, delaiReponse=-1)
	return JSON.generate({
		"type" => type,
		"data" => contenu,
		"delay" => delaiReponse
	})
end

def todata(str)
	return JSON.parse(str)
end
