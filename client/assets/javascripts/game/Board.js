// Plateau de jeu
function Board() {
	this.squares = [];

	this.init = function() {
		this.squares = [];
		// Creation of 42 cases
		for (var i = 0; i < Board.NBCASES; i++)
			this.squares.push(new Square());

		// Process player, put everybody on the 1st box
	}.bind(this);

	this.moveOf = function(player, pts) {
		// Player is no longer on this box
		player.box.unset(player);

		// We retrieve the new box
		var box = this.squares[(this.squares.indexOf(player.square)+pts)%Board.NBCASES];

		// Player is linked to his new box
		player.box = box;

		// Box know his new player
		box.push(player);

	}.bind(this);
}

Board.NBCASES = 42;
