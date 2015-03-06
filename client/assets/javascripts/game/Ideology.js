// Idéologies
function Ideology(name, slug, playerName, color, gaugesSet, confGauges) {
	this.name = name;
	this.slug = slug;
	this.playerName = playerName;
	this.color = new Color(color);
	this.optimalGauges = new Set();
	this.operations = [];
	this.events = [];

	for (var id in confGauges)
		this.optimalGauges.insert(id, gaugesSet.get(id).cloneAndConfig(confGauges[id]))
}
