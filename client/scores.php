<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('Scores');

menu();
banniere();
?>

<div id="conteneur">
<div id="corps">
	<h1>Scores</h1>
	
	<p>Résultats de la dernière partie jouée :</p>
	
	<table id="scores">
	<tr>
		<th>Joueur</th>
		<th colspan="2">Ideologie</th>
		<th>Domination géographique</th>
		<th>Respect idéologie</th>
	</tr>
	
	<?php
	$res = $mysqli->query('SELECT score_pseudo, score_respect_ideologie, score_domination_geo, ideo_nom, ideo_couleur
			FROM ideo_score
			JOIN ideo_ideologie ON ideo_id = score_ideologie_id
			ORDER BY score_date DESC, score_domination_geo DESC
			LIMIT 4');
			
	while ($score = $res->fetch_assoc()) {
		echo '
		<tr>
			<td>'.$score['score_pseudo'].'</td>
			<td style="background-color:#'.$score['ideo_couleur'].'; width:22px;"></td>
			<td>'.$score['ideo_nom'].'</td>
			<td>'.round($score['score_domination_geo']*100).' %</td>
			<td>'.round((1-$score['score_respect_ideologie'])*100).' %</td>
		</tr>';
	}
	?>
	
	</table>
	<p></p>
</div>
</div>

<?php
pied();
