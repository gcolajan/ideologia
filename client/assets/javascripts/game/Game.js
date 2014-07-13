// Stockage de l'état de la partie
function Game() {
	this.players = [];
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
}
