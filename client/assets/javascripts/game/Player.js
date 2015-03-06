// Joueur
function Player(pseudo, ideology) {
	this.pseudo = pseudo;
	this.ideology = ideology;
	this.funds = 0;
	this.position = 0;
	this.territories = new Set();

	/*this.updateTerritory = function(owner, health) {
		// TO REIMPLEM

		if (owner != this.owner) {
			if (this.owner !== undefined)
				this.owner.territories.unset(this.id);

			owner.territories.insert(this.id, this);
			this.owner = owner;
		}

		this.health = health;
	}.bind(this);*/

	this.applyOperation = function() {
		
	}.bind(this);
}
