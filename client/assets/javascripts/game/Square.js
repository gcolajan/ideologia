// Cases du plateau

function Square(kind) {
	this.kind = kind;
	this.params = undefined;
	this.players = new Collection(); // .push & .unset

	this.setParams = function(params) {
		switch (this.kind) {
			case Square.TERRITORY:
			case Square.EVENT:
				this.params = params;
				break;
			case Square.SQUAREONE:
				this.params = new Action(Target.ME, 0, 1);
				break;
		}
	}.bind(this);
}
// Some constants about the kind of the box
Square.TERRITORY = 'territory';
Square.EVENT = 'event'
Square.SQUAREONE = 'square one'; // case départ
