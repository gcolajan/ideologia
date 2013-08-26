Ideologia
=========

Game for browsers designed with Ruby, RoR and websockets.


Installation
------------

### Base de donnée

Récupération de la base de donnnée (répertoire /donnees) à importer dans une base de donnée MySQL.
Elle doit être commune au client et au serveur.

### Serveur

Fonctionne avec Ruby 1.9.3+ avec libmysql-ruby.

Préparation :
* dupliquer le fichier serveur/bibliotheques/ConnexionSQL.rb.example en ConnexionSQL.rb
* ajuster les paramètres de connexion à la base de donnée

Exécution :
* ruby serveur.rb \\* 8888

### Client

Fonctionne avec PHP 5+.

Préparation :
* dupliquer le fichier client/connexionSQL.php.example en connexionSQL.php
* ajuster les paramètres de connexion à la base de donnée
* client/plateau.php : vérifier l'adresse IP d'exécution du serveur pour la connexion websocket (ex : $_SERVER['SERVER_ADDR'])

Exécution :
* Ouvrez votre navigateur favoris permettant l'utilisation des websockets.
