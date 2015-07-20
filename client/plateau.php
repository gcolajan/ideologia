<?php
require 'ressources/entetes.php';
entete('Plateau');
$pseudo = (isset($_POST['pseudo']) ? $_POST['pseudo'] : 'pseudo unspecified');
?>
<div ng-controller="IdeologiaCtrl" id="IdeologiaCtrl">

	<div id="tracking">
		<svg>
		</svg>
	</div>

	<div class="row">
		<div id="header">
			<p>&nbsp;</p>
		</div>
	</div>

	<div class="row full-width">

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
				<h1 ng-click="moreData()">Observations</h1>

				<div id="timer"><span>{{timer}}</span></div>

				<ul class="players">
					<li ng-repeat="player in game.players" title="{{player.ideology.playerName}}" title="{{player.ideology.playerName}}">
						<i ng-style="{'color':player.ideology.color.css()}" class="icon-{{player.ideology.slug}}"></i> {{player.pseudo}}
					</li>
				</ul>

				<ul class="barcharts stats" title="Domination géographique">
					<li ng-repeat="p in game.players"> <!-- Domination -->
						<span ng-style="{'height':((p.territories.length() / game.territories.length) * 100)+'%', 'background-color':p.ideology.color.css()}"></span>
						<span class="number">{{((p.territories.length() / game.territories.length) * 100) | number:0}} %</span>
					</li>
				</ul>

				<ul class="barcharts stats inverted" title="Santé des idéologies">
					<li ng-repeat="p in game.players"> <!-- Health -->
						<span ng-style="{'height':p.getGlobalHealth() * 100+'%', 'background-color':p.ideology.color.css()}"></span>
						<span class="number">{{(p.getGlobalHealth() * 100) | number:0}} %</span>
					</li>
				</ul>


				<div class="details" ng-show="game.hoveredTerritory != undefined">
					<h2>Détails</h2>
					<dl>
						<dt>Territoire</dt>
						<dd>{{game.hoveredTerritory.name}}</dd>

						<dt>Propriétaire</dt>
						<dd>{{game.getOwnerOf(game.hoveredTerritory).pseudo}}</dd>

						<dt>Stabilité</dt>
						<dd ng-style="{'color':game.hoveredTerritory.getHealthColor().css()}">{{(game.hoveredTerritory.getHealth() * 100) | number:0}} %</dd>
					</dl>

					<ul class="barcharts">
						<li ng-repeat="gauge in game.hoveredTerritory.gauges.array">
							<span ng-style="{'height':gauge.currentLevel*100+'%', 'background-color':gauge.getHealthColor().css()}"></span>
							<span ng-style="{'height':gauge.optimalLevel*100+'%'}" class="optimal"></span>
							<span class="number">{{gauge.currentLevel*100 | number:0}} %</span>
							<span class="legend" ng-class="'icon-jauge-'+gauge.slug"></span>
						</li>
					</ul>
				</div>

				<div ng-hide="game.hoveredTerritory != undefined">
					<h2>Historique</h2>
					{{history}}
				</div>


			</div>
		</div>

		<div class="large-8 columns" id="map"><div class="mapel">

			<!-- WebSocket state message -->
			<div id="wsmsg" ng-show="wsInfo">{{wsMsg}}</div>

			<!-- PopUnder -->
			<div id="startup" ng-show="showPopunder()"><div class="conteneur" ng-include="currentPhase.getPopUnder()"></div></div>

			<!-- Select operation -->
			<div id="selectOperation" ng-show="game.choseOperation">
				<div class="conteneur">
					<h1>{{game.getCurrentTerritory().name}}</h1>
					<div class="territoryFrame">
						<svg vbox="{{game.getCurrentTerritory().getViewBox().get(10)}}">
							<g fill="#222222">
								<path ng-repeat="d in game.getCurrentTerritory().path" d="{{d}}" />
							</g>
						</svg>
					</div>

					<div class="operationsFrame">
						<ul>
							<li ng-click="trigger('sendOperation', id)" ng-repeat="id in game.currentOperations">{{game.operations.get(id).name}} ({{game.operations.get(id).getCost(game.getMe().ideology.id)}} $)</li>
						</ul>
					</div>

					<div style="clear:both;"></div>

					<div class="effectsFrame">
						Territoire possédé par <strong>{{game.getOwnerOf(game.getCurrentTerritory()).pseudo}}</strong>
					</div>

					<!-- Nom territoire, propriétaire, liste des opérations et affichage des effets (via matrice JSON obtenue en début de partie)-->
				</div>
			</div>

			<!-- Map -->
			<svg viewBox="0 0 1881 950">
				<g
						ng-repeat="terr in game.territories.list"
						fill="{{(terr.id == game.hoveredTerritory.id) ? 'rgba(255,255,255,0.33)' : terr.color.css()}}"
						ng-mouseenter="game.hoveredTerritory = terr"
						ng-mouseleave="game.hoveredTerritory = undefined"
						stroke="black" stroke-width="{{(terr.id == game.hoveredTerritory.id) ? 3 : 1}}" stroke-linecap="round">
					<path ng-repeat="d in terr.path" d="{{d}}" title="{{terr.name}}" />
				</g>
			</svg>
			<h1>{{gameName}}</h1>
		</div></div>

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
				<h1>Territoires possédés</h1>

				<ul class="territories">
					<li
							class="fade"
							ng-repeat="territory in game.getMe().territories.array"
							ng-class="{active: territory.id == game.hoveredTerritory.id, risk: territory.shift >= game.getThreshold()}"
							ng-mouseenter="game.hoveredTerritory = territory"
							ng-mouseleave="game.hoveredTerritory = undefined"
							ng-style="{'color':territory.getHealthColor().css()}">
						{{territory.name}}
					</li>
				</ul>
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
