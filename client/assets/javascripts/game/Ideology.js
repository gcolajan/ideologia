// Idéologies
function Ideology(name, slug, color) {
	this.name = name;
	this.slug = slug;
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
