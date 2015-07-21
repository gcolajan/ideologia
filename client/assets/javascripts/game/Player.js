// Joueur
function Player(pseudo, ideology) {
	this.pseudo = pseudo;
	this.ideology = ideology;
	this.funds = 0;
	this.position = 0;
	this.territories = new Set();

	this.getColoured = function() {
		return '<span style="color:'+this.ideology.color.css()+'" title="'+this.ideology.playerName+'">'+this.pseudo+'</span>';
	}.bind(this);

	this.getIconified = function() {
		return '<span style="color:'+this.ideology.color.css()+'" title="'+this.ideology.playerName+'"><i class="icon-'+this.ideology.slug+'"></i></span>';
	}.bind(this);

	this.getGlobalHealth = function() {
		var health = 0;
		for (var key in this.territories.array)
			health += this.territories.get(key).getHealth();
		return (health / this.territories.length());
	}.bind(this);

	this.getGlobalHealthColor = function() {
		return Health2Color(this.getGlobalHealth());
	}.bind(this);

	/*
	this.getGaugeSynthesis = function() {
		// Initialisation of the gauges at 0
		var synthesis = ideology.getNewGauges();
		for (var id in synthesis.array)
			synthesis.get(id).currentLevel = 0;

		// Put the values into our synthesis
		for (var id in this.territories.array)
		{
			var terr = this.territories.get(id);
			for (var k in terr.gauges.array)
				synthesis.get(k).currentLevel += terr.gauges.get(k).currentLevel;
		}

		// Processing the average
		for (var id in synthesis.array)
			synthesis.get(id).currentLevel /= this.territories.length();

		return synthesis;
	}.bind(this);*/

	this.applyOperation = function() {
		
	}.bind(this);

	this.addTerritory = function(territory) {
		// We reset his gauges
		territory.gauges = ideology.getNewGauges();

		// We color it
		territory.color = ideology.color.clone();
		territory.color.hueVariation();
		territory.color.alpha = 0.5;

		// We add it to our list
		this.territories.insert(territory.id, territory);
	}.bind(this);

	this.losingTerritory = function(id) {
		// We delete it from his list
		this.territories.unset(id);
	}.bind(this);
}
