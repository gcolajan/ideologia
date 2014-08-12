app.service('ws', function($rootScope) {

	var opened = false;
	var ws = new WebSocket("ws://127.0.0.1:8080");
	var callbacks = {};

	var status = '';

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
		on: function(eventName, callback) {
			callbacks[eventName] = callback;
		},
		emit: function(eventName, data) {
			var transmission = {};
			transmission.type = eventName;
			if (data !== undefined) {
				transmission.data = data;
			}
			console.log(transmission)
			ws.send(JSON.stringify(transmission));
		},
		close: function() {
			ws.close();
		}
	};

	ws.onmessage = function(e) {
		var msg = JSON.parse(e.data);
		if (callbacks[msg.type]) {
			var args = '';
			if (msg.data !== undefined)
				args = msg.data;

			$rootScope.$apply(callbacks[msg.type](args));
		}
		else
			console.log('Unregistered property');
	};

	callbacks.ping = function() { events.emit('pong'); }

	return events;
});
