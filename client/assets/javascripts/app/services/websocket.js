app.service('ws', function($rootScope) {

	var opened = false;
	var ws;
	var onMessageCallback = function() {};
	var onConnexionOpened = function() {};
	var onUnreachableServer = function() {};
	var onInterruptedSocket = function() {};
	var onClose = function() {};
	var callbacks = {};

	var declareEvents = function(ws) {

		window.addEventListener("beforeunload", function(event) {
			ws.close();
			ws = null;
		});


		ws.onopen = function() {
			opened = true;
			onConnexionOpened();
		};

		ws.onclose = function() {
			if (!opened)
				onUnreachableServer();
			else
				onInterruptedSocket();

			opened = false;
			onClose();
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
	};

	var events = {
		open: function(host, port) {
			var socket = new WebSocket("ws://"+host+":"+port);
			declareEvents(socket);
			ws = socket;
		},
		setOnMessageCallback: function(callback) {
			onMessageCallback = callback;
		},
		setOnConnexionOpened: function(callback) {
			onConnexionOpened = callback;
		},
		setOnUnreachableServer: function(callback) {
			onUnreachableServer = callback;
		},
		setOnInterruptedSocket: function(callback) {
			onInterruptedSocket = callback;
		},
		setOnClose: function(callback) {
			onClose = callback;
		},
		// For global purpose
		on: function(eventName, callback) {
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
