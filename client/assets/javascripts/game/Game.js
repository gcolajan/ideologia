// Stockage de l'état de la partie
function Game() {
	this.players = [];
	this.territories = new Collection();
	this.gauges = new Set();
	this.ideologies = new Set();
	this.currentPlayer = undefined;
	this.me = undefined;

	this.history = new History(10);

	this.events = new Set();
	this.operations = new Set();

	this.hoveredTerritory = undefined;
	this.concernedTerritory = undefined;
	this.lastConcernedTerritory = undefined;

	this.choseOperation = false;
	this.currentOperations = [];

	var that = this; // scope of "this"
	var $http = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('$http');
	$http.get('data.ajax.php')
		.success(function (result) {
			// Adding territories
			for (var id in  result['territory']) {
				var territory = result['territory'][id];
				that.territories.push(new Territory(
					id,
					territory['name'],
					territory['pos'],
					territory['path']));
			}

			// Adding gauges
			for (var id in result['gauge']) {
				var gauge = result['gauge'][id];
				that.gauges.insert(id, new Gauge(gauge['name'], gauge['slug']));
			}

			// Adding ideologies
			for (var id in result['ideology']) {
				var ideology = result['ideology'][id];
				that.ideologies.insert(
					id,
					new Ideology(
						id,
						ideology['name'],
						ideology['slug'],
						ideology['player'],
						ideology['color'],
						that.gauges,
						ideology['gauges']
					)
				);
			}

			for (var id in result['events']) {
				var event = result['events'][id];
				that.events.insert(
					id,
					new Event(
						id,
						event['name'],
						event['desc'],
						event['dest'],
						new Effects(
							event['effects']['abs'],
							event['effects']['rel']
						)
					)
				);
			}

			for (var id in result['operations']) {
				var operation = result['operations'][id];
				var curOperation = new Operation(
					id,
					operation['name'],
					operation['desc']
				);

				for (var ideo in operation['effects']) {
					var effect = operation['effects'][ideo];
					curOperation.addEffect(
						ideo,
						new Effects(
							effect['abs'],
							effect['rel']
						),
						effect['cost']
					);
				}

				that.operations.insert(
					id,
					curOperation
				);
			}
		})
		.error(function() {
			console.log('Game\'s data can\'t be reached!');
		});


	this.getMe = function() {
		return this.players[this.me];
	}.bind(this);

	this.getGauges = function() {
		if (this.hoveredTerritory == null)
			return undefined; //this.getMe().getGaugeSynthesis();
		else
			return this.hoveredTerritory.gauges.array;
	}.bind(this);

	this.getCurrentPlayer = function() {
		return this.players[this.currentPlayer];
	}.bind(this);

	this.amICurrent = function() {
		return (this.currentPlayer == this.me);
	}.bind(this);

	this.getConcernedPlayers = function(target) {
		switch (target) {
			case Target.ALL:
				return this.players;
			case Target.ME:
				return [this.players[this.me]];
			case Target.EXCEPTME:
				var concernedPlayers = new Array();
				for (var i ; i < Game.NBPLAYERS ; i++)
					if (i != this.me)
						concernedPlayers.push(this.players[i]);
				return concernedPlayers;
			default:
				return [];
		}
	}.bind(this);

	this.bindPlayers = function() {
		console.log("Bind "+this.players.length);
		for (var player in this.players) {
			console.log(this.players[player]);
			//this.players[player].game = this;
		}

	}.bind(this);

	this.getThreshold = function() {
		return Game.THRESHOLD;
	}.bind(this);

	this.getOwnerOf = function(territory) {
		if (territory == undefined)
			return undefined;

		for (var p in this.players)
			if (this.players[p].territories.exists(territory.id))
				return this.players[p];

		return undefined;
	}.bind(this);

	this.territoryAt = function(position) {
		return this.territories.get(position, 'position');
	}.bind(this);

	this.makeUserChose = function(operationsId) {
		this.currentOperations = operationsId;
		this.choseOperation = true;
	}.bind(this);

	this.getShownTerritory = function() {
		if (typeof this.hoveredTerritory !== 'undefined')
			return this.hoveredTerritory;
		else if (typeof this.concernedTerritory !== 'undefined')
			return this.concernedTerritory;

		// Fallback is "Europe occidentale"
		return this.territories.get(3, "id");

	}.bind(this);
}


Game.NBPLAYERS = 4;
Game.THRESHOLD = 0.30; // Maximum shift authorized (TODO: binding server)
