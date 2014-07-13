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

				<div id="startup"><div class="conteneur">
				<h1>Connexion</h1>
					<div id="status"></div>
					<ul id="waiting"></ul>
					<div id="formPseudo">
							<div class="row collapse">
								<div class="columns medium-10 small-8">
									<input type="text" name="pseudo" id="pseudo" placeholder="Pseudo" class="columns small-10" />
								</div>
								<div class="columns medium-2 small-4">
									<input type="submit" value="Continuer" class="button postfix" />
								</div>
							</div>
					</div>
					<div id="rooms" style="display:none"></div>
				</div></div>

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

	<script src="assets/javascripts/main.js?<?php echo uniqid(); ?>"></script>

	<script>
		function Equilibre(Indentifier){
			$(Indentifier).each(function(){
				var h=0;
				$(">*", this);
				$(Indentifier).each(function(){ h=Math.max(h,this.offsetHeight); }).css({'height': h+'px'});
			});
		}

		$(document).ready(function() {
			Equilibre(".mapel");
		});
	</script>

<?php
pied();
