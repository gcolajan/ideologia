<?php
require 'ressources/entetes.php';
entete('Ideologia');
?>

	<div id="header">
		<h1>Ideologia</h1>
	</div>

	<div id="accueil">	
		<form method="post" action="plateau.php">
			<input type="hidden" name="pseudo" value="<?php echo uniqid(); ?>" />
			<input type="submit" value="Jouer !" />
		</form>
	</div>

<?php
pied();