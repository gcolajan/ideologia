// Stockage de l'état de la partie
function Game() {
	this.players = [];
	this.territories = new Collection();
	this.currentPlayer = undefined;
	this.me = undefined;

	this.getMe = function() {
		return this.players[me];
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
}


Game.NBPLAYERS = 4;
