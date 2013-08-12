<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('Plateau');
?>

<div id="conteneur_notification" onclick="fermer(this)">
	<div id="notification">
		<div id="contenu_notification"></div>
		<div id="notification_des" class="listeners"><input type="button" id="lancer_des" value="Lancer les dés" /></div>
		<div id="notification_operation" class="listeners"><input type="button" id="envoyer_operation" value="Envoyer l'opération" /></div>
	</div>
</div>


<div id="attente">
	<?php include 'plateau/attente.php'; ?>
</div>


<div id="conteneur_plateau" style="display:none;">
	<?php include 'plateau/plateau.php'; ?>
</div>

<script type="text/javascript">
timer("timer");
setTimer(30,0);

<%= @terrCases.html_safe %> // terrCases {idTerr:idCase}
<%= @ideologies.html_safe %>
<%= @couleurs.html_safe %>
<%= @jauges_js.html_safe %>
<%= @listeTerritoires.html_safe %>
<%= @listeEvenements.html_safe %>
<%= @listeOperations.html_safe %>
<%= @listeCoutOperations.html_safe %>

var nbTerritoires = 32
var nbJoueurs = 4;
var nbJauges = 3;

var pseudo = "<%= @pseudo %>";
var ep_numJoueur = 0
var ep_jc = 0
var ep_partenaires = {}
var ep_niveauIdeals = {}
var ep_positions = {0:0, 1:0, 2:0, 3:0}
var toClean = Array()
var ep_fonds = 0
var ep_listeTerritoires = {}
var listenerActif = false;

var socket = new WebsocketClass('ws://10.42.0.100:8888');
socket.initWebsocket();


document.getElementById('envoyer_operation').addEventListener('click',function(e){
	e.preventDefault();
	socket.sendMessage(radioSelect("operation"));
	listenerActif = false;
	document.getElementById('notification_operation').style.display = 'none';
	return false;
},true);

document.getElementById('lancer_des').addEventListener('click',function(e){
	e.preventDefault();
	socket.sendMessage("des");
	listenerActif = false;
	document.getElementById('notification_des').style.display = 'none';
	return false;
},true);

</script>

<?php
pied();
