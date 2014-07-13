// Cases du plateau

function Box(kind) {
	this.kind = kind;
	this.params = undefined

	this.setParams = function(params) {
		switch (this.kind) {
			case Box.TERRITORY:
			case Box.EVENT:
				this.params = params;
				break;
			case Box.SQUAREONE:
				this.params = new Action(Target.ME, 0, 1);
				this.params.
				break;
		}
	}.bind(this);
}
// Some constants about the kind of the box
Box.TERRITORY = 'territory';
Box.EVENT = 'event'
Box.SQUAREONE = 'square one'; // case départ
