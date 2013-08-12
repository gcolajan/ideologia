<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('Connexion');

banniere();
menu();
?>

<div id="conteneur">
<div id="corps">
	<h1>Connexion</h1>
	<p>Ideologia est un jeu de plateau multijoueur basé sur des idéologies qui existent ou ont existé.
	Le but est de conquérir le plus de territoires possibles tout en respectant l'idéologie incarnée dès le départ.</p>
	<p>Une partie dure 30 minutes. Êtes-vous prêt à relever le défi ?</p>
	
	<form method="post" action="plateau.php">
		<fieldset class="connexion">
				<label for="pseudo">Pseudo</label>
				<input type="text" name="pseudo" id="pseudo" maxlength="32" />
				<label></label>
				<input type="submit" value="Connexion" />
		</fieldset>
	</form>
</div>
</div>

<?php
piedpage();
pied();
