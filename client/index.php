<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('Accueil');

menu();
banniere();
?>

<div id="conteneur">
<div id="corps">
	<h1>Bienvenue</h1>
	<p><em>Ideologia</em> est un jeu de plateau multijoueur ayant pour fond les batailles idéologiques.
	En tant que joueur, vous représentez une des quatre idéologies. Le but est de rallier les territoires ennemis à son idéologie tout en surveillant que vos territoires respectent au mieux l'idéologie que vous incarné afin de les conserver.</p>
	
	<p>Une partie dure <span id="tempsPartie">0</span> minutes.</p>
	
	<p>Êtes-vous prêt à relever le défi ? <span id="joueursPresents"></span></p>
	
	<form method="post" action="plateau.php">
		<fieldset class="connexion">
				<label for="pseudo">Pseudo</label>
				<input type="text" name="pseudo" id="pseudo" maxlength="32" />
				<label></label>
				<input type="submit" value="Jouer !" />
		</fieldset>
	</form>
</div>
</div>

<?php
pied();
