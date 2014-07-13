// Idéologies
function Ideology(name, color) {
	this.name = name;
	this.color = color;
	this.operations = [];
	this.events = [];

	this.getName = function() {
		return this.name;
	}.bind(this);

	this.getColor = function() {
		return this.color;
	}.bind(this);
}
