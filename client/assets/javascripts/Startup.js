function Startup() {

	$("#startup").hide();

	this.clean = function() {
		// On nettoie le panel startup
		$("#formPseudo").hide();
		$("#rooms").hide();
		$("#status").hide();
		$("#waiting").hide();
	}

	this.open = function() {
		$("#startup").show();
	}.bind(this);

	this.close = function() {
		$("#startup").hide();
	}.bind(this);

	this.showPseudoForm = function() {
		// On affiche le nécessaire pour rentrer le pseudo
		$('#formPseudo').show();

		// On déclare le listener associé au pseudo
	}.bind(this);

	this.cleanChans = function() {
		this.chans = '';
	}.bind(this);

	this.showChans = function() {
		$("#rooms").html(this.chans);
		$("#rooms").show();
	}.bind(this);

	// Affiche la coordonnée stockée
	this.addChan = function(id, nb) {
		this.chans += '\
			<div>\
				<h2>Salon #'+id+'</h2>\
				<div class="row collapse">\
					<div class="columns small-8"><p class="room-detail">'+((nb == 0) ? 'Aucun' : nb)+' joueur'+((nb>1)?'s':'')+'</p></div>\
					<div class="columns small-4"><input type="button" value="Rejoindre !" class="room-detail" onclick="ws.send(\'join\', '+id+');" /></div>\
				</div>\
			</div>';
	}.bind(this);

	// Le serveur nous confirme que l'on a rejoint un salon
	this.hasJoined = function() {
		//this.close();
	}.bind(this);

	this.cleanPseudos = function() {
		this.pseudos = '<input type="button" onclick="ws.send(\'deco\'); startup.clean(); startup.showChans();" value="Changer de salon" />';
	}.bind(this);

	this.addPseudo = function(pseudo) {
		this.pseudos += '<li>'+pseudo+'</li>';
	}.bind(this);

	this.showWaiting =function() {
		$("#waiting").html(this.pseudos);
		$("#waiting").show();
	}

	this.showInterruptedConnection = function() {
		this.clean();
		$('#status').html("La connexion avec le serveur a été interrompue !");
		$("#status").show();
		this.open();
	}


	this.showServerUnavailable = function() {
		this.clean();
		$('#status').html("Le serveur de jeu n'est pas disponible !");
		$("#status").show();
		this.open();
	}
}
