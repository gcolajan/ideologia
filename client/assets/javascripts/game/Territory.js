// Define the territories
function Territory(id, name, position, path) {

	this.id = id;
	this.name = name;
	this.position = position;
	this.path = path;
	this.pathViewBox = undefined;
	this.color = new Color(Math.round(Math.random()*255), 0.5);
	this.gauges = new Set();
	this.shift = 0;

	this.updateState = function(gaugesState) {
		this.shift = 0;
		for (var id in gaugesState)
		{
			var curGauge = this.gauges.get(id);
			curGauge.currentLevel = (gaugesState[id] / 100.0);
			this.shift += curGauge.getShift();
		}
	}.bind(this);

	this.getHealth = function() {
		var health = 1 - (this.shift / Game.THRESHOLD);
		if (health < 0.0) // The threshold can be exceeded
			health = 0.0;

		return health;
	}.bind(this);

	this.getHealthColor = function() {
		return Health2Color(this.getHealth());
	}.bind(this);

	this.getViewBox = function() {
		if (typeof this.pathViewBox === 'undefined')
			this.pathViewBox = new AutoViewBox(this.path);
		return this.pathViewBox;
	}.bind(this);
}

Territory.hoverColor = new Color(128, 0.2);
