<?php
/* JSON file that returns :
	- territory
	- gauge (names)
	- ideology (& lvl of gauges)
	- operations (matrix with name, desc, cost and effects)
	- events (name, desc, destination and effects)
*/
$dbh = new PDO('mysql:host=localhost;dbname=ideologia', 'root', 'larousse', array(PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8'));

$data = array();


/*******************
 	TERRITORY POP & POS
*******************/

$reqTerr = $dbh->query('SELECT terr_id, terr_position,
		(SELECT SUM(unite_population)
		FROM terr_unite
		WHERE unite_territoire = terr_id) AS popTerritoire
	FROM terr_territoire
	ORDER BY terr_id');

$data['territories'] = array();
foreach($reqTerr as $row) {
	$data['territories'][$row['terr_id']] = array(
		'population' => $row['popTerritoire'],
		'position'   => $row['terr_position']);
}


/*******************
 	IDEOLOGY
*******************/

$reqIdeo = $dbh->query('SELECT ideo_id FROM ideo_ideologie');

$data['ideology'] = array();
foreach($reqIdeo as $row) {
	$data['ideology'][] = $row['ideo_id'];
}


/*******************
 	EVENTS
*******************/

$reqEvents = $dbh->query('SELECT eo_id, eo_nom, eo_description, eo_destination, ee_jauge_id, ee_variation_absolue, ee_variation_pourcentage
	FROM ideo_evenement_operation
	LEFT JOIN ideo_evenement_effet ON eo_id = ee_operation_id
	ORDER BY eo_id, ee_jauge_id');

$data['events'] = array();
foreach($reqEvents as $row)
{
	if (!isset($data['events'][$row['eo_id']]))
		$data['events'][$row['eo_id']] = array(
			'dest'    => $row['eo_destination'],
			'effects' => array( // We set default value for abs & rel variation
				'abs' => array(1 => 0, 2 => 0, 3 => 0),
				'rel' => array(1 => 1, 2 => 1, 3 => 1)));

	$data['events'][$row['eo_id']]['effects']['abs'][$row['ee_jauge_id']] = $row['ee_variation_absolue'];
	$data['events'][$row['eo_id']]['effects']['rel'][$row['ee_jauge_id']] = $row['ee_variation_pourcentage'];
}


/*******************
 	OPERATIONS
*******************/

$reqCosts = $dbh->query('SELECT toc_operation_id, toc_ideologie_id, toc_cout
FROM ideo_territoire_operation_cout
ORDER BY toc_ideologie_id, toc_operation_id');

$costs = array();
foreach ($reqCosts as $row) {
	if (!isset($costs[$row['toc_ideologie_id']]))
		$costs[$row['toc_ideologie_id']] = array();

	$costs[$row['toc_ideologie_id']][$row['toc_operation_id']] = $row['toc_cout'];
}

$reqOpEffects = $dbh->query('SELECT te_operation_id, te_jauge_id, te_ideologie_id, te_variation_absolue, te_variation_pourcentage
FROM ideo_territoire_effet
ORDER BY te_ideologie_id, te_operation_id, te_jauge_id');

$data['operations'] = array();
foreach($reqOpEffects as $row) {
	if (!isset($data['operations'][$row['te_ideologie_id']]))
		$data['operations'][$row['te_ideologie_id']] = array();

	if (!isset($data['operations'][$row['te_ideologie_id']][$row['te_operation_id']]))
	{
		$data['operations'][$row['te_ideologie_id']][$row['te_operation_id']] = array(
			'cost' => isset($costs[$row['te_ideologie_id']][$row['te_operation_id']]) ? $costs[$row['te_ideologie_id']][$row['te_operation_id']] : null,
			'effects' => array(
				'abs' => array(1 => 0, 2 => 0, 3 => 0),
				'rel' => array(1 => 1, 2 => 1, 3 => 1)));
	}

	$data['operations'][$row['te_ideologie_id']][$row['te_operation_id']]['effects']['abs'][$row['te_jauge_id']] = $row['te_variation_absolue'];
	$data['operations'][$row['te_ideologie_id']][$row['te_operation_id']]['effects']['rel'][$row['te_jauge_id']] = $row['te_variation_pourcentage'];
}

/*******************
 	GAUGES
*******************/

$reqGauges = $dbh->query('SELECT caract_ideo_id, caract_jauge_id, caract_coeff_diminution, caract_coeff_augmentation, caract_ideal
          FROM ideo_jauge_caracteristique
          ORDER BY caract_ideo_id, caract_jauge_id');

$data['gauges'] = array();
foreach($reqGauges as $row)
{
	if (!isset($data['gauges'][$row['caract_ideo_id']]))
		$data['gauges'][$row['caract_ideo_id']] = array();

		$data['gauges'][$row['caract_ideo_id']][$row['caract_jauge_id']] = array(
			'ideal' => $row['caract_ideal'],
			'plus'  => $row['caract_coeff_augmentation'],
			'minus' => $row['caract_coeff_diminution']
		);
}


ob_start();
echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_NUMERIC_CHECK);
$json = ob_get_contents();
ob_end_clean();

// Écrit le résultat dans le fichier
file_put_contents('./data.json', $json);
