// Stockage de l'état de la partie
function Game() {
	this.players = [];
	this.territories = new Collection();
	this.gauges = new Set();
	this.ideologies = new Set();
	this.currentPlayer = undefined;
	this.me = undefined;

	this.hoveredTerritory = null;

	this.getMe = function() {
		return this.players[this.me];
	}.bind(this);

	this.getGauges = function() {
		if (this.hoveredTerritory == null)
			return undefined; //this.getMe().getGaugeSynthesis();
		else
			return this.hoveredTerritory.gauges.array;
	}.bind(this);

	this.getCurrentPlayer = function() {
		return this.players[currentPlayer];
	}.bind(this);

	this.amICurrent = function() {
		return (this.currentPlayer == this.me);
	}.bind(this);

	this.getConcernedPlayers = function(target) {
		switch (target) {
			case Target.ALL:
				return this.players;
			case Target.ME:
				return [this.players[this.me]];
			case Target.EXCEPTME:
				var concernedPlayers = new Array();
				for (var i ; i < Game.NBPLAYERS ; i++)
					if (i != this.me)
						concernedPlayers.push(this.players[i]);
				return concernedPlayers;
			default:
				return [];
		}
	}.bind(this);

	this.bindPlayers = function() {
		console.log("Bind "+this.players.length);
		for (var player in this.players) {
			console.log(this.players[player]);
			//this.players[player].game = this;
		}

	}.bind(this);

	this.getThreshold = function() {
		return Game.THRESHOLD;
	}.bind(this);

	this.getOwnerOf = function(territory) {
		if (territory == undefined)
			return undefined;

		for (var p in this.players)
			if (this.players[p].territories.exists(territory.id))
				return this.players[p];

		return undefined;
	}.bind(this);
}


Game.NBPLAYERS = 4;
Game.THRESHOLD = 0.30; // Maximum shift authorized (TODO: binding server)
