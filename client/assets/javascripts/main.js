var startup = new Startup();
var chan;
var game;

var ws = $.websocket("ws://localhost:8080/", {
	events: {
		ping: function(e) {
			ws.send('pong', '');
		},
		status: function(e) {
			switch (e.data) {
				case 'ready':
					startup.clean();
					startup.showPseudo();
					break;
				default:
					console.log("Status received: "+e.data);
			}
		},
		salons: function(e) {
			startup.clean();
			for (var id in e.data)
				startup.addChan(id, e.data[id]);
			startup.showChans();
		},
		joined: function(e) {
			startup.hasJoined();
			chan = e.data;
			// Je décide d'aller dans CE salon
		},
		waitingWith: function(e) {
			startup.clean();
			for (var pseudo in e.data)
				startup.addPseudo(e.data[pseudo]);
			startup.showWaiting();
		},
		numeroJoueur: function(e) {
			console.log('Je suis le joueur '+e.data);
		},
		scores: function(e) {
			console.log('Ci-après, les scores !');
			console.log(e.data);
		},
		partenaires: function(e) {
			console.log('Ci-après, partenaires :');
			console.log(e.data);
		},
		jaugesIdeales: function(e) {
			console.log('Ci-après, des données de config, mes jauges idéales');
			console.log(e.data);
		},
		temps: function(e) {
			console.log('Le temps restant jusqu\'à la fin de la partie');
			console.log(e.data);
		},
		evenement: function(e) {
			console.log('Un événèment est reçu');
			console.log(e.data);
		},
		listeTerritoires: function(e) {
			console.log('Un petit résumé des territoires: ');
			console.log(e.data);
		},
		positions: function(e) {
			console.log('Liste des positions');
			console.log(e.data);
		},
		pcases: function(e) {
			console.log('Qui est sur quelle case');
			console.log(e.data);
		},
		fonds: function(e) {
			console.log('Quels sont mes fonds disponibles ?');
			console.log(e.data);
		},
		jauges: function(e) {
			console.log('Et l\'état de mes jauges');
			console.log(e.data);
		},
		operations: function(e) {
			console.log('Je reçois une liste d\'opérations');
			console.log(e.data);
			console.log('Et je renvoie n\'importe quoi, le serveur se débrouillera (le serveur m\'attend 30s max)');
			ws.send('operation', 0);
		},
		des: function(e) {
			console.log('Le résultat de mon lancé de dés');
			console.log(e.data);
		},
		position: function(e) {
			console.log('');
			console.log(e.data);
		},
		gain: function(e) {
			console.log('');
			console.log(e.data);
		},
		joueurCourant: function(e) {
			console.log('Je reçois le joueur courant');
			console.log(e.data);

			console.log('Si c\'est à moi de jouer, faut lancer les dés !');
			ws.send('des', '');
		},
		deconnexion: function(e) {
			console.log('On me dit que quelqu\'un s\'est deconnecté...');
			console.log(e.data);
		},
	}
});

$('#pseudo').change(function() {
  ws.send('pseudo', this.value);
  this.disabled = true;
});
