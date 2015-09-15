// Idéologies
function Ideology(id, name, slug, playerName, color, gaugesSet, confGauges) {
	this.id = id;
	this.name = name;
	this.slug = slug;
	this.playerName = playerName;
	this.color = new Color(color);
	this.optimalGauges = new Set();
	this.operations = [];
	this.events = [];

	for (var id in confGauges)
		this.optimalGauges.insert(id, gaugesSet.get(id).cloneAndConfig(confGauges[id]))

	this.getNewGauges = function() {
		var gauges = new Set();

		for (var id in this.optimalGauges.array)
			gauges.insert(id, this.optimalGauges.get(id).clone());

		return gauges;
	}
}
