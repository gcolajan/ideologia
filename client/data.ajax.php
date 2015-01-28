<?php
/* JSON file that returns :
	- territory
	- gauge (names)
	- ideology (& lvl of gauges)
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
			'nom'      => $row['terr_nom'],
			'position' => intval($row['terr_position']),
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
			'nom'     => $row['ideo_nom'],
			'slug'    => $row['ideo_slug'],
			'joueur'  => $row['ideo_joueur'],
			'couleur' => array(intval($row['ideo_r']), intval($row['ideo_g']), intval($row['ideo_b'])),
			'jauges'  => array());

	if (!isset($data['ideology'][$row['ideo_id']]['jauges'][$row['caract_jauge_id']]))
		$data['ideology'][$row['ideo_id']]['jauges'][$row['caract_jauge_id']] = floatval($row['caract_ideal']);
}

// Print the content
echo json_encode($data);
