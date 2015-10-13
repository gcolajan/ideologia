<?php 

function entete($titre) {
	echo '<!DOCTYPE html>
	<html>
	<head>
		<title>'.$titre.' - Ideologia</title>
		
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		
		<link rel="stylesheet" href="assets/stylesheets/normalize.css" />
		<link rel="stylesheet" href="assets/stylesheets/design.css" />
		<link rel="stylesheet" href="assets/stylesheets/fonts.css" />

		<script src="assets/javascripts/vendors/jquery/jquery.min.js"></script>
	</head>
	<body ng-app="myGame">';
}

function pied() {
	echo '
	<script src="assets/javascripts/vendors/angular/angular.min.js"></script>
	<script src="assets/javascripts/vendors/angular/angular-route.min.js"></script>
	<script src="assets/javascripts/vendors/angular/angular-animate.min.js"></script>

	<script src="assets/javascripts/tools.concat.js"></script>
	<script src="assets/javascripts/game.concat.js"></script>
	<script src="assets/phases/phases.concat.js"></script>
	<script src="assets/javascripts/app.concat.js"></script>


	<script>
		function FixedMap(){
			var map = $("#svgmap");
			var height = map.height();
			map.css("margin-top", -Math.round(height/2));
		}
		$(document).ready(function() {
			FixedMap();
		});
		$(window).resize(function() {
			FixedMap();
		});
	</script>

	</body>
	</html>';
}
