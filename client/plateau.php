<?php
require 'ressources/entetes.php';
entete('Plateau');
$pseudo = (isset($_POST['pseudo']) ? $_POST['pseudo'] : 'pseudo unspecified')

?>

	<div class="row">
		<div id="header">
			<p>&nbsp;</p>
		</div>		
	</div>

	<div class="row full-width">

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
				<h1>Observations</h1>
				
				<div id="timer"><span>09:59</span></div>

				<h2>Adversaires</h2>
				<h2>Historique</h2>
				<h2>Détails</h2>
			</div>
		</div>

		<div class="large-8 columns" id="map">
			<div class="mapel">
				<img src="carte.svg" /><br />
				<h1>Ideologia</h1>
			</div>
		</div>
		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
				<h1>Commandement</h1>
			</div>
		</div>
	</div>

	<dl id="plateau">
		<?php
		$jActives = array();
		for($j = 1 ; $j <= 4 ; $j++)
			$jActives[$j] = rand(1, 42);
		
		for ($i = 1 ; $i <= 42 ; $i++)
		{
			echo '
			<dt>
				<span class="case '.($i%5 == 0 ? 'danger' : '').'">'.$i.'</span>

				<span class="joueurs">';
				for($j = 1 ; $j <= 4 ; $j++)
					echo '<span class="joueur j'.$j.'"><span class="'.(($jActives[$j] == $i) ? 'active' : '').'"></span></span>';

			echo'</span>
			</dt>';
		}

		?>
	</dl>

	<div style="height:80px"></div>



		<script>

		var ws = $.websocket("ws://localhost:8080/", {
			events: {
				ping: function(e) {
					ws.send('pong', '');
				},
				status: function(e) {
					console.log('Le serveur me donne le statut courant');
					console.log(e.data);
					ws.send('pseudo', 'MON PSEUDO !');
				},
				chans: function(e) {
					console.log('Les salons disponibles');
					console.log(e.data);
				},
				join: function(e) {e
					// Je décide d'aller dans CE salon
				},
				numeroJoueur: function(e) {
					console.log('Je suis le joueur '+e.data);
				},
				scores: function(e) {
					console.log('Ci-après, les scores !');
					console.log(e.data);
				},
				partenaires: function(e) {
					console.log('Ci-après, partenaires :');
					console.log(e.data);
				},
				jaugesIdeales: function(e) {
					console.log('Ci-après, des données de config, mes jauges idéales');
					console.log(e.data);
				},
				temps: function(e) {
					console.log('Le temps restant jusqu\'à la fin de la partie');
					console.log(e.data);
				},
				evenement: function(e) {
					console.log('Un événèment est reçu');
					console.log(e.data);
				},
				listeTerritoires: function(e) {
					console.log('Un petit résumé des territoires: ');
					console.log(e.data);
				},
				positions: function(e) {
					console.log('Liste des positions');
					console.log(e.data);
				},
				pcases: function(e) {
					console.log('Qui est sur quelle case');
					console.log(e.data);
				},
				fonds: function(e) {
					console.log('Quels sont mes fonds disponibles ?');
					console.log(e.data);
				},
				jauges: function(e) {
					console.log('Et l\'état de mes jauges');
					console.log(e.data);
				},
				operations: function(e) {
					console.log('Je reçois une liste d\'opérations');
					console.log(e.data);
					console.log('Et je renvoie n\'importe quoi, le serveur se débrouillera (le serveur m\'attend 30s max)');
					ws.send('operation', 0);
				},
				des: function(e) {
					console.log('Le résultat de mon lancé de dés');
					console.log(e.data);
				},
				position: function(e) {
					console.log('');
					console.log(e.data);
				},
				gain: function(e) {
					console.log('');
					console.log(e.data);
				},
				joueurCourant: function(e) {
					console.log('Je reçois le joueur courant');
					console.log(e.data);

					console.log('Si c\'est à moi de jouer, faut lancer les dés !');
					ws.send('des', '');
				},
				deconnexion: function(e) {
					console.log('On me dit que quelqu\'un s\'est deconnecté...');
					console.log(e.data);
				},
			}
		});

		$('#pseudo').change(function(){
		  ws.send('pseudo', this.value);
		  this.disabled = true;
		  $('#message').removeAttr('disabled');
		});

		$('#message').change(function(){
		  ws.send('chat', this.value);
		  this.value = '';
		});

		$('#join').click(function(){
		  ws.send('game', 'join');
		});









		function Equilibre(Indentifier){
			 $(Indentifier).each(function(){
		   var h=0;
		   $(">*", this)
		     $(Indentifier).each(function(){ h=Math.max(h,this.offsetHeight); })
		     .css({'height': h+'px'});
		 });
		 }


		$(document).ready(function() {
			Equilibre(".mapel");
		});
		</script>

		<div style="clear:both;"></div>

		<div id="pied">-</div>



<?php
pied();