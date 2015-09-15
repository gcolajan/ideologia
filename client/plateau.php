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

	<div id="history">
		<ul>
			<li ng-repeat="msg in game.history.data">
				<span class="date">{{msg.time}}</span>
				<span ng-bind-html="msg.content | html"></span>
			</li>
		</ul>
	</div>

	<div id="front"></div>

	<div class="row full-width">

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel">
			<div ng-show="currentPhase.name == 'jeu'">
				<h2>Actions</h2>

				<!-- Who's playing on what -->
				<div class="currentAction" ng-bind-html="game.currentPlayDescription | html"></div>

				<!--
				<div class="partners">
					<ul class="barcharts stats" title="Domination géographique">
						<li ng-repeat="p in game.players">
							<span ng-style="{'height':((p.territories.length() / game.territories.length) * 100)+'%', 'background-color':p.ideology.color.css()}"></span>
							<span class="number">{{((p.territories.length() / game.territories.length) * 100) | number:0}} %</span>
						</li>
					</ul>

					<ul class="barcharts stats inverted" title="Santé des idéologies">
						<li ng-repeat="p in game.players">
							<span ng-style="{'height':p.getGlobalHealth() * 100+'%', 'background-color':p.ideology.color.css()}"></span>
							<span class="number">{{(p.getGlobalHealth() * 100) | number:0}} %</span>
						</li>
					</ul>
				</div>-->

				<!-- Select operation -->
				<div class="selectOperation" ng-show="game.choseOperation">
					<div class="operationsFrame">
						<ul>
							<li
									ng-click="game.setSelectedOperation(id)"
									ng-class="{active: game.selectedOperation.id == id}"
									ng-repeat="id in game.currentOperations">
								<span class="cost" ng-class="{'negative': game.operations.get(id).getCost(game.getOwnerOf(game.concernedTerritory).ideology.id) <= 0}">
									${{game.operations.get(id).getCost(game.getOwnerOf(game.concernedTerritory).ideology.id)}}
								</span>
								<span class="operation">{{game.operations.get(id).name}}</span>
							</li>
						</ul>
					</div>

					<div ng-show="game.selectedOperation !== undefined">
						<p class="text-center">
							<button ng-click="trigger('sendOperation', game.selectedOperation.id)">Valider</button>
						</p>

						<div class="operationSimulation">
							<h3>{{game.selectedOperation.name}}</h3>
							<span>{{game.selectedOperation.getCost(game.getCurrentPlayer().ideology.id)}} $</span>
							<span>{{game.selectedOperation.desc}}</span>

							<div ng-hide="game.currentSimulation.changeOwnership && game.getOwnerOf(game.concernedTerritory) != game.getMe()">
								<ul class="barcharts currentSimulation">
									<li ng-repeat="gauge in game.currentSimulation.gauges.array">
										<span ng-style="{'height':gauge.currentLevel*100+'%', 'background-color':gauge.getHealthColor().css()}"></span>
										<span ng-style="{'height':gauge.optimalLevel*100+'%'}" class="optimal"></span>
										<span class="number">{{gauge.currentLevel*100 | number:0}} %</span>
										<span class="legend" ng-class="'icon-jauge-'+gauge.slug"></span>
									</li>
								</ul>

								<p>Stabilité : {{game.currentSimulation.evolution}} %</p>
							</div>

							<div ng-show="game.currentSimulation.changeOwnership && game.getOwnerOf(game.concernedTerritory) != game.getMe()">
								Le territoire basculera sous votre égide !
							</div>
						</div>
					</div>
				</div>


			</div>
			</div>
		</div>

		<div class="large-8 columns" id="map"><div class="mapel">

			<!-- WebSocket state message -->
			<div id="wsmsg" ng-show="wsInfo">{{wsMsg}}</div>

			<!-- PopUnder -->
			<div id="startup" ng-show="showPopunder()"><div class="conteneur" ng-include="currentPhase.getPopUnder()"></div></div>


			<h1>{{gameName}}</h1>

			<!-- Map -->
			<svg viewBox="0 0 1881 950">
				<g
						ng-repeat="terr in game.territories.list"
						fill="{{(terr.id == game.hoveredTerritory.id) ? 'rgba(255,255,255,0.33)' : (terr.id == game.concernedTerritory.id ? '#222222' : terr.color.css())}}"
						ng-mouseenter="game.hoveredTerritory = terr"
						ng-mouseleave="game.hoveredTerritory = undefined"
						stroke="{{terr.id == game.concernedTerritory.id ? 'red' : 'black'}}" stroke-width="{{(terr.id == game.hoveredTerritory.id || terr.id == game.concernedTerritory.id) ? 3 : 1}}" stroke-linecap="round">
					<path ng-repeat="d in terr.path" d="{{d}}" />
				</g>
			</svg>

			<ul class="players">
				<li ng-repeat="player in game.players" ng-class="{active: game.getCurrentPlayer() == player}" title="{{player.ideology.playerName}}">
					<i ng-style="{'color':player.ideology.color.css()}" class="icon-{{player.ideology.slug}}"></i>
					<br />
					<span ng-class="{bold: player == game.getMe()}">{{player.pseudo}}</span>
				</li>
			</ul>
		</div></div>

		<div class="large-2 columns" id="mypan">
			<div class="mypanel mapel" ng-show="currentPhase.name == 'jeu'">
				<!-- Details on hovered territory -->
				<h2 class="nowrap">{{game.getShownTerritory().name}}</h2>

				<!-- Concerned territory (by the current player) -->
				<div class="territoryFrame">
					<svg vbox="{{game.getShownTerritory().getViewBox().get(10)}}">
						<g fill="rgba(255,255,255,0.6)">
							<path ng-repeat="d in game.getShownTerritory().path" d="{{d}}" />
						</g>
					</svg>
				</div>

				<div class="hoveredTerritory">
					<span class="owner" ng-bind-html="game.getOwnerOf(game.getShownTerritory()).getIconified() | html"></span>

					<br />

					<span class="stability" ng-style="{'background-color':game.getShownTerritory().getHealthColor().css()}">
						{{(game.getShownTerritory().getHealth() * 100) | number:0}} %
					</span>
				</div>

				<ul class="barcharts hoveredTerrChart">
					<li ng-repeat="gauge in game.getShownTerritory().gauges.array">
						<span ng-style="{'height':gauge.currentLevel*100+'%', 'background-color':gauge.getHealthColor().css()}"></span>
						<span ng-style="{'height':gauge.optimalLevel*100+'%'}" class="optimal"></span>
						<span class="number">{{gauge.currentLevel*100 | number:0}} %</span>
						<span class="legend" ng-class="'icon-jauge-'+gauge.slug"></span>
					</li>
				</ul>


				<div class="menuSep"></div>

				<!-- My own territories -->
				<h2>Territoires possédés</h2>

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

				+ indicateur évolution
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
