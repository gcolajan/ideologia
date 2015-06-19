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
 	TERRITORY
*******************/

$reqTerr = $dbh->query('SELECT terr_id, terr_nom, terr_position, path_d
FROM terr_territoire
JOIN terr_territoire_path ON path_territoire = terr_id
ORDER BY terr_id');

$data['territory'] = array();
foreach($reqTerr as $row) {
	if (!isset($data['territory'][$row['terr_id']]))
		$data['territory'][$row['terr_id']] = array(
			'name'      => $row['terr_nom'],
			'pos' => intval($row['terr_position']),
			'path'     => array());
	$data['territory'][$row['terr_id']]['path'][] = $row['path_d'];
}


/*******************
 	GAUGE
*******************/

$reqGauges = $dbh->query('SELECT jauge_id, jauge_nom, jauge_slug FROM ideo_jauge
	ORDER BY jauge_slug');

$data['gauge'] = array();
foreach($reqGauges as $row)
	$data['gauge'][$row['jauge_id']] = array(
		'name' => $row['jauge_nom'],
		'slug' => $row['jauge_slug']);

/*******************
 	IDEOLOGY
*******************/

$reqIdeo = $dbh->query('SELECT ideo_id, ideo_joueur, ideo_nom, ideo_slug, ideo_r, ideo_g, ideo_b,
caract_jauge_id, caract_ideal
FROM ideo_ideologie
JOIN ideo_jauge_caracteristique ON caract_ideo_id = ideo_id
ORDER BY ideo_id, caract_jauge_id');

$data['ideology'] = array();
foreach($reqIdeo as $row) {
	if (!isset($data['ideology'][$row['ideo_id']]))
		$data['ideology'][$row['ideo_id']] = array(
			'name'    => $row['ideo_nom'],
			'slug'    => $row['ideo_slug'],
			'player'  => $row['ideo_joueur'],
			'color'   => array(intval($row['ideo_r']), intval($row['ideo_g']), intval($row['ideo_b'])),
			'gauges'  => array());

	if (!isset($data['ideology'][$row['ideo_id']]['gauges'][$row['caract_jauge_id']]))
		$data['ideology'][$row['ideo_id']]['gauges'][$row['caract_jauge_id']] = floatval($row['caract_ideal']);
}


/*******************
 	OPERATIONS DESC
*******************/

$reqOperations = $dbh->query('SELECT to_id, to_nom, to_description
FROM ideo_territoire_operation
ORDER BY to_id');

$names = array();
$descs = array();
foreach($reqOperations as $row) {
	$names[$row['to_id']] = $row['to_nom'];
	$descs[$row['to_id']] = $row['to_description'];
}

/*******************
 	OPERATIONS MATRIX
*******************/

$reqCosts = $dbh->query('SELECT toc_operation_id, toc_ideologie_id, toc_cout
FROM ideo_territoire_operation_cout
ORDER BY toc_operation_id, toc_ideologie_id');

$costs = array();
foreach ($reqCosts as $row) {
	if (!isset($costs[$row['toc_operation_id']]))
		$costs[$row['toc_operation_id']] = array();

	$costs[$row['toc_operation_id']][$row['toc_ideologie_id']] = $row['toc_cout'];
}

$reqOpEffects = $dbh->query('SELECT te_operation_id, te_jauge_id, te_ideologie_id, te_variation_absolue, te_variation_pourcentage
FROM ideo_territoire_effet
ORDER BY te_operation_id, te_ideologie_id, te_jauge_id');

$data['operations'] = array();
foreach($reqOpEffects as $row) {
	if (!isset($data['operations'][$row['te_operation_id']]))
	{
		$data['operations'][$row['te_operation_id']]['name'] = $names[$row['te_operation_id']];
		$data['operations'][$row['te_operation_id']]['desc'] = $descs[$row['te_operation_id']];
		$data['operations'][$row['te_operation_id']]['effects'] = array();
	}

	if (!isset($data['operations'][$row['te_operation_id']]['effects'][$row['te_ideologie_id']]))
		$data['operations'][$row['te_operation_id']]['effects'][$row['te_ideologie_id']] = array(
			// We set default value for abs & rel variation
			'cost' => isset($costs[$row['te_operation_id']][$row['te_ideologie_id']]) ? $costs[$row['te_operation_id']][$row['te_ideologie_id']] : null,
			'abs' => array(1 => 0, 2 => 0, 3 => 0),
			'rel' => array(1 => 1, 2 => 1, 3 => 1));

	$data['operations'][$row['te_operation_id']]['effects'][$row['te_ideologie_id']]['abs'][$row['te_jauge_id']] = $row['te_variation_absolue'];
	$data['operations'][$row['te_operation_id']]['effects'][$row['te_ideologie_id']]['rel'][$row['te_jauge_id']] = $row['te_variation_pourcentage'];
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
			'name'    => $row['eo_nom'],
			'desc'    => $row['eo_description'],
			'dest'    => $row['eo_destination'],
			'effects' => array( // We set default value for abs & rel variation
				'abs' => array(1 => 0, 2 => 0, 3 => 0),
				'rel' => array(1 => 1, 2 => 1, 3 => 1)));

	$data['events'][$row['eo_id']]['effects']['abs'][$row['ee_jauge_id']] = $row['ee_variation_absolue'];
	$data['events'][$row['eo_id']]['effects']['rel'][$row['ee_jauge_id']] = $row['ee_variation_pourcentage'];
}

// Print the content
echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_NUMERIC_CHECK);
