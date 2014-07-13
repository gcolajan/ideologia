function Startup() {

	this.chans = '';

	this.clean = function() {
		// On nettoie le panel startup
		$("#formPseudo").hide();
		$("#rooms").hide();
	}

	this.close = function() {
		$("#startup").hide();
	}.bind(this);

	this.showPseudo = function() {
		// On affiche le nécessaire pour rentrer le pseudo
		$('#formPseudo').show();

		// On déclare le listener associé au pseudo
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
		this.close();
	}.bind(this);
}
