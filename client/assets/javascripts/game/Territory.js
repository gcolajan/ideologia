// Define the territories
function Territory(id, name, position, path) {

	this.id = id;
	this.name = name;
	this.position = position;
	this.path = path;
	this.color = new Color(Math.round(Math.random()*255), 0.5);
	this.shift = 0;

	this.getHealth = function() {
		var health = 1 - (this.shift / Game.THRESHOLD);
		if (health < 0.0) // The threshold can be exceeded
			health = 0.0;

		return health;
	}.bind(this);

	this.getHealthColor = function() {
		return Health2Color(this.getHealth());
	}.bind(this);
}

Territory.hoverColor = new Color(128, 0.2);
