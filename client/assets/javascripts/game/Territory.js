// Define the territories
function Territory(id, name, position, path) {
	this.id = id;
	this.name = name;
	this.position = position;
	this.path = path;
	this.color = new Color(Math.round(Math.random()*255), 0.5);

	this.health = -1;

	this.setHealth = function(health) {
		this.health = health;
	}.bind(this);
}