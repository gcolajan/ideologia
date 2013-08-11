var WebsocketClass = function(host){
	this.socket = new WebSocket(host);
	this.console = document.getElementsByClassName('console')[0];
};

WebsocketClass.prototype = {
	initWebsocket : function(){
		var $this = this;
		this.socket.onopen = function(){
			$this.onOpenEvent(this);
		};
		this.socket.onmessage = function(e){
			$this._onMessageEvent(e);
		};
		this.socket.onclose = function(){
			$this._onCloseEvent();
		};
		this.socket.onerror = function(error){
			$this._onErrorEvent(error);
		};
	},
	_onErrorEvent :function(err){
		console.log(err);
	},
	onOpenEvent : function(socket){
		this.console.innerHTML = this.console.innerHTML + 'socket opened, status ' + socket.readyState + '<br>';
		// À l'ouverture de la socket, on envoie le pseudo du joueur au serveur
		this.socket.send(pseudo);
	},
	_onMessageEvent : function(e){
		routeur(e.data);
	},
	_onCloseEvent : function(){
		this.console.innerHTML = this.console.innerHTML + 'websocket closed - server not running<br>';
		document.location="./scores";
		//Affiche la fermeture de la socket
	},
	sendMessage : function(mess){
		// Deux transmissions possibles : le lancé de dés ou une opération
		if(mess=="des")
			this.socket.send("");
		else
			this.socket.send(mess);
	}
};

