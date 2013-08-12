<?php 

function entete($titre='Ideologia') {
	echo '<!DOCTYPE html>
	<html>
	<head>
		<title>'.$titre.' - Ideologia</title>
		
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		
		<link rel="stylesheet" href="assets/stylesheets/application.css" />
		<link rel="stylesheet" href="assets/stylesheets/plateau.css" />
		<link rel="stylesheet" href="assets/stylesheets/notification.css" />
		<link rel="stylesheet" href="assets/stylesheets/panel.css" />
		<link rel="stylesheet" href="assets/stylesheets/pages.css" />
		
		<script language="Javascript" src="assets/javascripts/affichage.js"></script>
		<script language="Javascript" src="assets/javascripts/rgb.js"></script>
		<script language="Javascript" src="assets/javascripts/outils.js"></script>
		<script language="Javascript" src="assets/javascripts/timer.js"></script>
		<script language="Javascript" src="assets/javascripts/routeur.js"></script>
		<script language="Javascript" src="assets/javascripts/controleurs.js"></script>
		<script language="Javascript" src="assets/javascripts/WebsocketClass.js"></script>
	</head>
	<body>';
}

function pied() {
	echo '</body>';
	echo '</html>';
}

function banniere() {
	echo '<div id="header_conteneur"><div id="header">&nbsp;</div></div>';
}

function menu() {
	echo '<div id="speedbar">
	<ul>
		<li><a href="#">Accueil</a></li>
		<li><a href="#">Projet</a></li>
		<li><a href="#">Équipe</a></li>
		<li><a href="#">Contact</a></li>
	</ul>
	</div>';
}

function piedpage() {
	echo '<div id="conteneur_footer">
		<div id="footer">
			<p><a href="#">Nous contacter</a><br />
			Projet réalisé par des étudiants de l\'IUT-BM<br />
			2012-2013</p>
		</div>
	</div>';
}
?>
