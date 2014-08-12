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

	<div class="row full-width" ng-controller="IdeologiaCtrl">

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
				<h1>Observations</h1>
				
				<div id="timer"><span>{{timer}}</span></div>

				<h2>Adversaires</h2>
				{{enmies}}
				<h2>Historique</h2>
				{{history}}
				<h2>Détails</h2>
				{{details}}
			</div>
		</div>

		<div class="large-8 columns" id="map">
			<div class="mapel">

				<div id="startup" ng-show="showPopunder()"><div class="conteneur">
				<h1>{{popunderTitle}}</h1>
					<div id="status"></div>
					<ul id="waiting"></ul>
					<form ng-show="currentPhase == 'introduction'" ng-submit="sendPseudo()">
					<div id="formPseudo">
							<div class="row collapse">
								<div class="columns medium-10 small-8">
									<input type="text" name="pseudo" ng-model="pseudo" id="pseudo" placeholder="Pseudo" class="columns small-10" />
								</div>
								<div class="columns medium-2 small-4">
									<input type="submit" value="Continuer" class="button postfix" />
								</div>
							</div>
					</div>
					</form>
					<div id="rooms" ng-show="currentPhase == 'salons'">
						<div ng-repeat="salon in salons">
						<h2>Salon #{{$index}}</h2>
						<div class="row collapse">
							<div class="columns small-8"><p class="room-detail">{{salon}} joueur(s)</p></div> <!-- ((salon == 0) ? 'Aucun' : salon)+' joueur'+((salon>1)?'s') -->
							<div class="columns small-4"><input type="button" value="Rejoindre !" class="room-detail" ng-click="joinSalon($index)" /></div>
						</div>
						</div>						
					</div>
					<div ng-show="currentPhase == 'attente'">
						<ul>
							<li ng-repeat="joueur in adversaires">{{joueur}}</li>
						</ul>
					</div>
				</div></div>

				<img src="carte.svg" /><br />
				<h1>{{game}}</h1>
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



<?php
pied();
