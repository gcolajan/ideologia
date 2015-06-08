// Jauge
function Gauge(name, slug, level) {
	this.name = name;
	this.slug = slug;
	this.optimalLevel = level || 1.0;
	this.currentLevel = level || 1.0;

	this.clone = function() {
		return new Gauge(this.name, this.slug, this.optimalLevel);
	}.bind(this);

	this.cloneAndConfig = function(level) {
		return new Gauge(this.name, this.slug, level);
	}.bind(this);

	this.reset = function() {
		this.currentLevel = this.optimalLevel;
	}.bind(this);

	this.getShift = function() {
		return Math.abs(this.optimalLevel - this.currentLevel);
	}.bind(this);

	this.getHealthColor = function() {
		var color = Health2Color(1 - this.getShift() / 0.66);
		color.alpha = 0.5;
		return color;
	}.bind(this);
}
