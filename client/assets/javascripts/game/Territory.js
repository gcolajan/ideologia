// Define the territories
function Territory(id, name, position, path) {
	this.id = id;
	this.name = name;
	this.position = position;
	this.path = path;

	var greyLevel = Math.round(Math.random()*255);
	this.color = "rgba("+greyLevel+", "+greyLevel+", "+greyLevel+", 0.5)";

	this.health = -1;

	this.setHealth = function(health) {
		this.health = health;
	}.bind(this);
}