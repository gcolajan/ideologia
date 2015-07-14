function Operation(id, name, desc) {
	this.id = id;
	this.name = name;
	this.desc = desc;
	this.effects = new Set();
	this.costs = new Set();

	/**
	 * Add an effect to the list from an ideology (id expected + Effect instance)
	 * @type {function(this:Operation)}
	 */
	this.addEffect = function(ideology, effect, cost) {
		this.effects.insert(ideology, effect);
		this.costs.insert(ideology, cost);
	}.bind(this);

	/**
	 * Returns the effect of the operation for an ideology (id expected).
	 * @type {function(this:Operation)}
	 */
	this.getEffect = function(ideology) {
		return this.effects.get(ideology);
	}.bind(this);

	/**
	 * Returns the cost when the operation is processed by an ideology
	 * @param ideology
	 * @returns {*}
	 */
	this.getCost = function(ideology) {
		return this.costs.get(ideology);
	}
}
