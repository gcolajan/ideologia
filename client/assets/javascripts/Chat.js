// Objet Chat permettant d'utiliser le chat pour différentes choses : discussions, résumé du jeu, et debug

function Chat() {}

Chat.prototype.chat = function(content){this.write('chat', content);}
Chat.prototype.game = function(content){this.write('game', content);}
Chat.prototype.info = function(content){this.write('info', content);}
Chat.prototype.neutral = function(content){this.write('neutral', content);}
Chat.prototype.debug = function(content){this.write('debug', content);}
Chat.prototype.heure = function() {
	now = new Date();

	heure = now.getHours()+":";

	if (now.getHours() < 10)
		heure = "0"+heure;

	if (now.getMinutes() < 10)
		heure = "0";
	
	heure += now.getMinutes();

	return heure;
}
Chat.prototype.write = function(level, content) {
	$('#chatBox').append('<span class="chat_'+level+'" title="'+this.heure()+'">'+content+'</span>');
	$("#chatBox").attr({ scrollTop: $("#chatBox").attr("scrollHeight") });
}