<?php
require 'ressources/entetes.php';
entete('Ideologia');
?>

	<div id="header">
		<h1>Ideologia</h1>
	</div>

	<div id="popunder" class="intro">
		<div>
			<p>Ideologia est un projet initié par 8 étudiants.</p>

			<p>Nous sommes actuellement deux développeurs sur ce projet, les principes sont troubles mais nous tâcherons de vous les fournir sous peu.</p>

			<p>Nous vous proposons quelques mots clés :</p>
			<ul>
				<li>jeu de plateau</li>
				<li>domination géographique</li>
				<li>prévalence idéologique</li>
			</ul>

			<p>
				Retrouvrez le projet sur <a href="https://github.com/gcolajan/ideologia">github</a>.

			</p>

			<form method="get" action="plateau.php" class="text-center">
				<input type="submit" value="Jouer !" class="button"  />
			</form>
		</div>
	</div>

<?php
pied();