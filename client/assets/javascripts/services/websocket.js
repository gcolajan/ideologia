app.service('ws', function($rootScope) {

	var opened = false;
	var ws = new WebSocket("ws://127.0.0.1:8080");
	var callbacks = {};
	var currentPhase = undefined;

	var status = '';

	callbacks.ping = function() { events.emit('pong'); };

	window.addEventListener("beforeunload", function(event) {
		ws.close();
		ws = null;
	});

	ws.onopen = function() {
		status = 'WS opened';
		opened = true;
	};

	ws.onclose = function() {
		if (!opened)
			console.log('Impossible d\'établir la connexion');
		else
			console.log('Connexion interrompue !');

		console.log('WS closed');
	};


	var events = {
		registerPhase: function(phase) {
			currentPhase = phase;
		},
		// For global purpose
		on: function(eventName, callback) {
			console.log('Global event: '+eventName);
			callbacks[eventName] = callback;
		},
		emit: function(eventName, data) {
			var transmission = {};
			transmission.type = eventName;
			if (data !== undefined) {
				transmission.data = data;
			}
			ws.send(JSON.stringify(transmission));
		},
		close: function() {
			ws.close();
		}
	};

	ws.onmessage = function(e) {
		var msg = JSON.parse(e.data);
		var args = '';
		if (msg.data !== undefined)
			args = msg.data;

		// First, if can be caught by the phase callback
		if (currentPhase !== undefined && currentPhase.isStarted() && currentPhase.operations.exists(msg.type)) {
			$rootScope.$apply(currentPhase.getOperation(msg.type)($rootScope, args));
		}
		else if (callbacks[msg.type]) {
			$rootScope.$apply(callbacks[msg.type](args));
		}
		else
			console.log('Unregistered property: '+msg.type);
	};

	return events;
});
