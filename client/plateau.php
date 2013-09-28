<?php
include 'inclusions.php';
include 'connexionSQL.php';

entete('Plateau');

$terrCases = array(); // JS
$territoires = array(); // JS

$contenuCases = array(); // data processing
$typesCases = array(); // data processing
$typesCases[0] = 'depart';

$i = 0;
$res = $mysqli->query('SELECT terr_id, terr_nom, terr_position FROM terr_territoire ORDER BY terr_position');
while ($terr = $res->fetch_assoc())
{
	$contenuCases[$terr['terr_position']] = array('id' => $terr['terr_id'], 'nom' => $terr['terr_nom']);
	$terrCases[] = $terr['terr_id'].':'.$terr['terr_position']; // terrCases {idTerr:idCase}
	$territoires[] = $terr['terr_id'].':"'.$terr['terr_nom'].'"';
	
	++$i;
	while ($terr['terr_position'] != $i)
	{
		$typesCases[$i] = 'evenement';
		++$i;
	}
	
	$typesCases[$i] = 'territoire';
}

// Si les dernières cases sont des événements, il faut alors l'indiquer en dehors de la requête
for (++$i ; $i < 42 ; ++$i)
	$typesCases[$i] = 'evenement';
	
$typ = '';
foreach ($typesCases as $pos => $type)
	$typ .= $pos.':\''.$type.'\',';

$typesCaseJS = 'typesCases = {'.substr($typ,0,-1).'}';
$terrCases = 'terrCases = {'.implode($terrCases, ',').'}';
$territoires = 'territoires = {'.implode($territoires, ',').'}';

$ideologies = array();
$couleurs = array();
$res = $mysqli->query('SELECT ideo_id, ideo_nom, ideo_couleur FROM ideo_ideologie ORDER BY ideo_id');
while ($ideo = $res->fetch_assoc())
{
	$ideologies[] = '"'.$ideo['ideo_nom'].'"';
	$couleurs[] = '"#'.$ideo['ideo_couleur'].'"';
}

$ideologies = 'ideologies = ['.implode($ideologies, ',').']';
$couleurs = 'couleurs = ['.implode($couleurs, ',').']';

$listeJauges = array();
$jauges = array();
$res = $mysqli->query('SELECT jauge_id, jauge_nom FROM ideo_jauge ORDER BY jauge_id');
while ($jauge = $res->fetch_assoc())
{
	$listeJauges[$jauge['jauge_id']] = $jauge['jauge_nom'];
	$jauges[] = '"'.$jauge['jauge_nom'].'"';
}

$jauges = 'jauges = ['.implode($jauges, ',').']';

// Liste des événements
$evenements = array();
$res = $mysqli->query('SELECT eo_id, eo_nom, eo_description, eo_destination FROM ideo_evenement_operation ORDER BY eo_id');
while ($ev = $res->fetch_assoc())
	$evenements[] = $ev['eo_id'].':{"nom":"'.$ev['eo_nom'].'","desc":"'.$ev['eo_description'].'","dest":'.$ev['eo_destination'].'}';

$evenements = 'jeu_evenements = {'.implode($evenements, ',').'}';

// Liste des opérations
$operations = array();
$res = $mysqli->query('SELECT to_id, to_nom, to_description FROM ideo_territoire_operation ORDER BY to_id');
while ($ev = $res->fetch_assoc())
	$operations[] = $ev['to_id'].':{"nom":"'.$ev['to_nom'].'","desc":"'.$ev['to_description'].'"}';

$operations = 'jeu_operations = {'.implode($operations, ',').'}';

// Coûts des opérations par idéologie
$coutsOp = array();
$res = $mysqli->query('SELECT toc_operation_id, toc_ideologie_id, toc_cout FROM ideo_territoire_operation_cout ORDER BY toc_ideologie_id, toc_operation_id');
while ($ev = $res->fetch_assoc())
	$coutsOp[$ev['toc_ideologie_id']][] = $ev['toc_operation_id'].':'.$ev['toc_cout'];

foreach ($coutsOp as $k => $v)
	$coutsOp[$k] = $k.':{'.implode($coutsOp[$k], ',').'}';

$coutsOp = 'jeu_couts = {'.implode($coutsOp, ',').'}';
?>

<div id="conteneur_notification" onclick="fermer(this)">
	<div id="notification">
		<div id="contenu_notification"></div>
		<div id="notification_des" class="listeners"><input type="button" id="lancer_des" value="Lancer les dés" /></div>
		<div id="notification_operation" class="listeners"><input type="button" id="envoyer_operation" value="Envoyer l'opération" /></div>
	</div>
</div>


<div id="attente">
	<?php include 'plateau/attente.php'; ?>
</div>


<div id="conteneur_plateau"> <!-- style="display:none;">-->
	<?php include 'plateau/plateau.php'; ?>
</div>

<script type="text/javascript">
timer("timer");
setTimer(30,0);

<?php 
echo $jauges."\n";
echo $ideologies."\n";
echo $couleurs."\n";
echo "\n";
echo $terrCases."\n";
echo $typesCaseJS."\n";
echo $territoires."\n";
echo "\n";
echo $evenements."\n";
echo $operations."\n";
echo $coutsOp."\n";
?>

var nbTerritoires = 32
var nbJoueurs = 4;
var nbJauges = 3;

var pseudo = "<?php echo htmlentities($_POST['pseudo']); ?>";
var ep_numJoueur = 0
var ep_jc = 0
var ep_partenaires = {}
var ep_niveauIdeals = {}
var ep_positions = {0:0, 1:0, 2:0, 3:0}
var toClean = Array()
var ep_fonds = 0
var ep_listeTerritoires = {}
var listenerActif = false;

var socket = new WebsocketClass('ws://127.0.0.1:8888');
socket.initWebsocket();


document.getElementById('envoyer_operation').addEventListener('click',function(e){
	e.preventDefault();
	socket.sendMessage(radioSelect("operation"));
	listenerActif = false;
	document.getElementById('notification_operation').style.display = 'none';
	return false;
},true);

document.getElementById('lancer_des').addEventListener('click',function(e){
	e.preventDefault();
	socket.sendMessage("des");
	listenerActif = false;
	document.getElementById('notification_des').style.display = 'none';
	return false;
},true);

</script>

<?php
pied();
