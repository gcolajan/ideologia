<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('À propos');

menu();
banniere();
?>

<div id="conteneur">
<div id="corps">
	<h1>À propos</h1>
		
	<p><em>Ideologia</em> est un projet tuteuré réalisé par 7 étudiants de l'IUT Informatique de Belfort-Montbéliard. Il a débuté en mars 2012 pour s'achever un an plus tard. Ce projet n'a pas été abandonné mais repris et déposé sur <a href="https://github.com/gcolajan/ideologia">GitHub</a> afin d'ouvrir notre travail aux critiques.</p>
	
	<p>Aujourd'hui, ce projet est toujours en développement.</p>
	
	<p>Pour plus de détails sur la réalisation de ce projet durant sa période scolaire, retrouvez les différents rapports réalisés :</p>
	<ul>
		<li><a href="./rapports/ideologia_pedagogique.pdf" title="Rapport au format PDF">rapport pédagogique</a> ;</li>
		<li><a href="./rapports/ideologia_technique.pdf" title="Rapport au format PDF">rapport technique</a>.</li>
	</ul>
	
	<p>Enfin, si vous désirez nous contacter, vous le pourrez très prochainement !</p>
</div>
</div>

<?php

pied();
?>
