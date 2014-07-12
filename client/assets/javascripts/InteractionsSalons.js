function InteractionsSalons() {

	$("#rooms").html('');
	this.content = '';

	// Affiche la coordonnée stockée
	this.addSalon = function(id, nb) {
		this.content += '\
			<div>\
				<h2>Salon #'+id+'</h2>\
				<div class="row collapse">\
					<div class="columns small-8"><p class="room-detail">'+((nb == 0) ? 'Aucun' : nb)+' joueur'+((nb>1)?'s':'')+'</p></div>\
					<div class="columns small-4"><input type="button" value="Rejoindre !" class="room-detail" onclick="ws.send(\'join\', '+id+');" /></div>\
				</div>\
			</div>';
	}.bind(this);

	this.show = function() {
		$("#rooms").html(this.content);
		$("#rooms").show();
	}.bind(this);
}
