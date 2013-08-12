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
?>
