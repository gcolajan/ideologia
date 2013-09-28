<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('Démo & Règles');

menu();
banniere();
?>

<div id="conteneur">
<div id="corps">
	<h1>Qu'est-ce qu'Ideologia ?</h1>
	
	<h2>Règles</h2>
	<p><em>Ideologia</em> est un jeu de plateau. Vous débuterez avec un certain nombre de territoires et une idéologie à suivre :</p>
	<ul>
		<li>l'idéologie communiste ;</li>
		<li>l'idéologie libérale ;</li>
		<li>l'idéologie anarchiste ;</li>
		<li>l'idéologie appuyée sur l'économie féodale.</li>
	</ul>
	
	<p>Chaque idéologie a des impératifs représentés par des jauges, selon votre idéologie vous devrez maintenir un niveau plus ou moins elevé sur chacune de ces jauges :</p>
	<ul>
		<li>la jauge économique ;</li>
		<li>la jauge environnementale ;</li>
		<li>la jauge sociale.</li>
	</ul>
	
	<p>Ce triplet de jauges est propre à chaque territoire et sera influencé par des événements et les actions qui y seront appliqués. En vous éloignant des objectifs de votre idéologie, vous risquez de voir basculer ce territoire chez un autre joueur. Votre objectif est donc de conserver vos territoires tout en frappant les autres afin qu'ils finissent par vous appartenir.</p>
	
	<p>Pour un tour de plateau, vous disposez d'une somme fixe à dépenser en frappant plus ou moins fort sur les territoires que vous rencontrerez. Cette somme allouée varie en fonction du nombre de la taille de la population que vous administrez.</p>
	
	<p>À la fin du temps imparti, jusqu'à deux vainqueurs sont désignés. L'un par rapport à la domination géographique : celui qui aura réussi à réunir le plus de territoires, et l'autre par rapport au respect de son idéologie au sein des territoires qu'il possède à la fin de la partie.</p>
	
	<h2>Démonstration</h2>
	
	<p>Dès que possible.</p>
	
</div>
</div>

<?php

pied();
?>
