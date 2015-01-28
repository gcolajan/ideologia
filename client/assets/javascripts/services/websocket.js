app.service('ws', function($rootScope) {

	var opened = false;
	var ws = new WebSocket("ws://127.0.0.1:8080");
	var onMessageCallback = function() {};
	var callbacks = {};

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

	ws.onmessage = function(e) {
		var msg = JSON.parse(e.data);
		var args = '';
		if (msg.data !== undefined)
			args = msg.data;

		if (callbacks[msg.type]) {
			$rootScope.$apply(callbacks[msg.type](args));
		}
		else {
			$rootScope.$apply(onMessageCallback(msg.type, args));
		}
	};


	var events = {
		setOnMessageCallback: function(fct) {
			onMessageCallback = fct;
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

	return events;
});
