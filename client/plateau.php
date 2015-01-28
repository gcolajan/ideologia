<?php
require 'ressources/entetes.php';
entete('Plateau');
$pseudo = (isset($_POST['pseudo']) ? $_POST['pseudo'] : 'pseudo unspecified');
?>
<div ng-controller="IdeologiaCtrl" id="IdeologiaCtrl">
		
	

	<div class="row">
		<div id="header">
			<p>&nbsp;</p>
		</div>		
	</div>

	<div class="row full-width">

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
				<h1>Observations</h1>
				
				<div id="timer"><span>{{timer}}</span></div>
				

				<h2>Historique</h2>
				{{history}}

				<h2>Détails</h2>
				{{currentTerr.nom}}
			</div>
		</div>

		<div class="large-8 columns" id="map">
			<div class="mapel">
			<div class="indicateurs">
				<ul>
					<li title="Social-politique"><i class="icon-jauge-social"></i></li>
					<li title="Finances"><i class="icon-jauge-finances"></i></li>
					<li title="Environnement"><i class="icon-jauge-environnement"></i></li>
				</ul>
			</div>

			<div class="adversaires">
				<h2>Adversaires</h2>
				<ul>
					<li class="ideo-liberal"><i class="icon-liberal"></i> Libéral</li>
					<li class="ideo-communisme"><i class="icon-communisme"></i> Communiste</li>
					<li class="ideo-anarchie"><i class="icon-anarchie"></i> Anarchiste</li>
					<li class="ideo-feodal"><i class="icon-feodal"></i> Chevalier</li>
				</ul>
			</div>

			<!-- PopUnder -->
			<div id="startup" ng-show="showPopunder()"><div class="conteneur" ng-include="currentPhase.getPopUnder()"></div></div>

			
			<svg viewBox="0 0 1881 950">
				<g ng-repeat="terr in territoires" fill="{{terr.couleur}}" stroke="rgba(255,255,255,0.66)" stroke-width="1" stroke-linecap="round" ng-mouseover="onTerritoire(terr)" ng-mouseleave="leaveTerritoire()">
					<path ng-repeat="d in terr.path" d="{{d}}" />
				</g>
			</svg>
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
		<dt ng-repeat="square in board.squares">
			<span class="case">{{$index+1}}</span>
			<span class="joueurs">
				<span class="ideology {{p.ideology.slug}}" ng-repeat="p in square.players" title="{{j.pseudo}}"></span>
			</span>
		</dt>

	</dl>

	<div style="height:80px"></div>
</div>


<?php
pied();
