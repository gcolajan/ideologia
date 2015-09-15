// Jauge
function Gauge(name, slug, level, minus, plus) {
	this.name = name;
	this.slug = slug;
	this.optimalLevel = level || 1.0;
	this.currentLevel = level || 1.0;

	this.minus = minus || 1.0;
	this.plus =  plus || 1.0;

	this.clone = function() {
		return new Gauge(this.name, this.slug, this.optimalLevel, this.minus, this.plus);
	}.bind(this);

	this.duplicate = function() {
		var gauge = this.clone();
		gauge.currentLevel = this.currentLevel;
		return gauge;
	}.bind(this);

	this.cloneAndConfig = function(conf) {
		return new Gauge(this.name, this.slug, conf['ideal'], conf['minus'], conf['plus']);
	}.bind(this);

	this.reset = function() {
		this.currentLevel = this.optimalLevel;
	}.bind(this);

	this.getShift = function() {
		return Math.abs(this.optimalLevel - this.currentLevel);
	}.bind(this);

	this.getHealthColor = function() {
		var staggering = 1 - this.getShift() / (2/3 * Game.THRESHOLD);
		if (staggering < 0) staggering = 0;
		var color = Health2Color(staggering);
		color.alpha = 0.5;
		return color;
	}.bind(this);

	this.applyEffect = function(relative, absolute) {
		console.log("*"+relative+"  +"+absolute+" ("+this.name+")");

		var level = Math.round(((this.currentLevel * relative) + (absolute / 100.0))*100)/100.0;

		// Application of the coefficients
		if (level >= this.currentLevel)
			level *= this.plus;
		else (level < this.currentLevel)
			level *= this.minus;

		if (level > 1.0)
			this.currentLevel = 1.0;
		else if (level < 0.0)
			this.currentLevel = 0.0;
		else
			this.currentLevel = level;
	}
}
