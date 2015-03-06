// Jauge
function Gauge(name, slug, level) {
	this.name = name;
	this.slug = slug;
	this.optimalLevel = level || 1.0;
	this.currentLevel = level || 1.0;

	this.cloneAndConfig = function(level) {
		return new Gauge(this.name, this.slug, level);
	}.bind(this);

	this.reset = function() {
		this.currentLevel = this.optimalLevel;
	}.bind(this);
}
