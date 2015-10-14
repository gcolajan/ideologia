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
	this.previousHealth = 0.0;
	this.showingDiff = '';

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

	this.getHealthDiff = function() {
		return this.getHealth() - this.previousHealth;
	}.bind(this);

	this.getHealthDiffColor = function() {
		var diff = Math.round(this.getHealthDiff()*100);
		if (diff > 0)
			return '<span title="'+diff+' %" style="color:green"><i class="icon-increase"></i></span>';
		else if (diff == 0.0)
			return '<span title="'+diff+' %" style="color:blue"><i class="icon-equal"></i></span>';
		else
			return '<span title="'+diff+' %" style="color:red"><i class="icon-decrease"></i></span>';
	}.bind(this);

	// We store our current health into the previous health attribute
	this.saveHealth = function() {
		this.previousHealth = this.getHealth();
	}.bind(this);

	this.refreshDiff = function() {
		this.showingDiff = this.getHealthDiffColor();
	}.bind(this);

	this.getViewBox = function() {
		if (typeof this.pathViewBox === 'undefined')
			this.pathViewBox = new AutoViewBox(this.path);
		return this.pathViewBox;
	}.bind(this);

	this.getSimulation = function(effects) {
		var shift = 0;
		var myGauges = new Set();

		for (var id = 1 ; id <= 3 ; id++) {
			myGauges.insert(id, this.gauges.array[id].duplicate());
		}

		effects.apply(myGauges);

		for (var id = 1 ; id <= 3 ; id++)
			shift += myGauges.get(id).getShift();

		return {
			gauges: myGauges,
			evolution: Math.round(((this.shift - shift)/Game.THRESHOLD)*100),
			changeOwnership: shift>Game.THRESHOLD
		};
	}.bind(this);
}

Territory.hoverColor = new Color(128, 0.2);
