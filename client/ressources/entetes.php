<?php 

function entete($titre) {
	echo '<!DOCTYPE html>
	<html>
	<head>
		<title>'.$titre.' - Ideologia</title>
		
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		
		<link rel="stylesheet" href="assets/stylesheets/normalize.css?'.uniqid().'" />
		<link rel="stylesheet" href="assets/stylesheets/design.css?'.uniqid().'" />
		<link rel="stylesheet" href="assets/stylesheets/foundation.min.css" />
		<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
		
		<script src="http://www.google.com/jsapi"></script>
		<script>google.load("jquery", "1.3")</script>
		<script src="http://jquery-json.googlecode.com/files/jquery.json-2.2.min.js"></script>
		<script src="assets/javascripts/jquery.ws.js?'.uniqid().'"></script>';

		if($dir = opendir('./assets/javascripts/game'))
			while (($file = readdir($dir)) !== false)
				if ($file != '.' AND $file != '..')
					echo '
		<script src="assets/javascripts/game/'.$file.'?'.time().'"></script>'; 

echo '
		<script src="assets/javascripts/Startup.js?'.uniqid().'"></script>
		<script src="assets/javascripts/constants.js?'.uniqid().'"></script>

		<link href="http://fonts.googleapis.com/css?family=Cabin:700|Electrolize" rel="stylesheet" type="text/css" />

	</head>
	<body>

	<nav class="top-bar" data-topbar>
		<ul class="title-area">
			<li class="name">
				<h1><a href="#">Ideologia</a></h1>
			</li>
			<li class="toggle-topbar menu-icon"><a href="#">Menu</a></li>
		</ul>

		<section class="top-bar-section">
			<ul class="right">
				<li><a href="https://github.com/gcolajan/ideologia">GitHub</a></li>
			</ul>
		</section>
	</nav>
';
}


function pied() {
	echo '</body>';
	echo '</html>';
}
