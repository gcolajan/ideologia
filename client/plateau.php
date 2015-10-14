<?php
require 'ressources/entetes.php';
entete('Plateau');
$pseudo = (isset($_POST['pseudo']) ? $_POST['pseudo'] : 'pseudo unspecified');
?>
<div ng-controller="IdeologiaCtrl" id="IdeologiaCtrl">

	<!-- Tracking -->
	<div id="tracking">
		<svg>
		</svg>
	</div>

	<!-- TopBar -->
	<div id="topbar">
		<ul>
			<li>
				<h1>Ideologia</h1>
				<h2 ng-show="game.started">
					<span ng-bind-html="game.getMe().getIconified() | html"></span>
					<span ng-bind-html="game.getMe().getColoured() | html"></span></h2>
			</li>
			<li ng-show="game.started">
				<span ng-bind-html="game.currentPlayDescription | html"></span>
			</li>
			<li ng-show="game.started">
				<span>TIMER</span>
				<span>{{game.getMe().funds}}&nbsp;$</span>
			</li>
		</ul>
	</div>

	<!-- Bottom bar -->
	<div id="bottombar" ng-show="currentPhase.name == 'jeu'">

		<div id="bottomCharts">
			<div class="globalCharts">
				<h4>Domination<br />géographique</h4>
				<ul class="barcharts global">
					<li ng-repeat="player in game.players" title="{{(player.getNbTerritories()/game.territories.length)*100 | number:0}} %">
						<span ng-style="{'height':(player.getNbTerritories()/game.territories.length)*100+'%', 'background-color':player.ideology.color.css()}"></span>
						<span class="legend" ng-class="'icon-'+player.ideology.slug"></span>
					</li>
				</ul>
			</div>

			<div class="globalCharts">
				<h4>Respect idéologie</h4>
				<ul class="barcharts global">
					<li ng-repeat="player in game.players" title="{{(player.getGlobalHealth()/game.territories.length)*100 | number:0}} %">
						<span ng-style="{'height':(player.getGlobalHealth()/game.territories.length)*100+'%', 'background-color':player.ideology.color.css()}"></span>
						<span class="legend" ng-class="'icon-'+player.ideology.slug"></span>
					</li>
				</ul>
			</div>
		</div>


		<!-- Current players -->
		<ul class="players">
			<li ng-repeat="player in game.players" ng-class="{active: game.getCurrentPlayer() == player, concerned: game.getOwnerOf(game.getShownTerritory()) == player}" title="{{player.ideology.playerName}}">
				<i ng-style="{'color':player.ideology.color.css()}" class="icon-{{player.ideology.slug}}"></i>
				<span ng-style="{'color':player.ideology.color.css()}">{{player.ideology.playerName}}</span><br />
				<span ng-class="{bold: player == game.getMe()}">{{player.pseudo}}</span>
			</li>
		</ul>
	</div>

	<!-- WebSocket state message -->
	<div id="wsmsg" ng-show="wsInfo">{{wsMsg}}</div>

	<!-- PopUnder -->
	<div id="popunder" ng-show="showPopunder()" ng-include="currentPhase.getPopUnder()"></div>


	<!-- Left Panel -->
	<div class="left panel" ng-show="currentPhase.name == 'jeu'">
		<h2>Dernières actions</h2>

		<!-- History -->
		<div id="history">
			<div class="dir next" ng-show="game.history.canGoNext()"><a href="#next" ng-click="game.history.goNext()">&gt;</a></div>
			<div class="dir prev" ng-show="game.history.canGoPrev()"><a href="#prev" ng-click="game.history.goPrev()">&lt;</a></div>
			<div class="date">{{game.history.getCurrent().time}}</div>

			<div class="msg" ng-bind-html="game.history.getCurrent().content | html"></div>
		</div>

		<h2>Action courante</h2>

		<!-- Select operation -->
		<div class="selectOperation" ng-show="game.choseOperation">
			<div class="operationsFrame">
				<div class="operation"
					 ng-click="game.setSelectedOperation(op)"
					 ng-class="{active: game.selectedOperation.id == op.id}"
					 ng-repeat="op in game.currentOperations.array">
					<h3>{{op.name}}</h3>
					<div class="descOp">
						<span>{{game.currentSimulations.get(op.id).evolution}} %</span>
						<span class="cost" ng-class="{'negative': op.getCost(game.getOwnerOf(game.concernedTerritory).ideology.id) <= 0}">
							{{op.getCost(game.getOwnerOf(game.concernedTerritory).ideology.id)}}&nbsp;$
						</span>
					</div>
				</div>
			</div>

			<div ng-show="game.selectedOperation !== undefined">
				<div class="operationSimulation">

					<p class="desc">{{game.selectedOperation.desc}}</p>

					<div style="clear:both;"></div>

					<ul class="barcharts currentSimulation" ng-hide="game.currentSimulations.get(game.selectedOperation.id).changeOwnership" style="width:200px;">
						<li ng-repeat="gauge in game.currentSimulations.get(game.selectedOperation.id).gauges.array">
							<span ng-style="{'height':gauge.currentLevel*100+'%', 'background-color':gauge.getHealthColor().css()}"></span>
							<span ng-style="{'height':gauge.optimalLevel*100+'%'}" class="optimal"></span>
							<span class="number">{{gauge.currentLevel*100 | number:0}} %</span>
							<span class="legend" ng-class="'icon-jauge-'+gauge.slug"></span>
						</li>
					</ul>

					<p ng-show="game.currentSimulations.get(game.selectedOperation.id).changeOwnership"><strong>
						Le territoire est suffisamment faible pour basculer !
					</strong></p>

					<p class="text-center">
						<button ng-click="trigger('sendOperation', game.selectedOperation.id)">Valider</button>
					</p>
				</div>
			</div>
		</div>
	</div>


	<!-- Right panel -->
	<div class="right panel" ng-show="currentPhase.name == 'jeu'">
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
				{{territory.name}} <span ng-bind-html="territory.showingDiff | html"></span>
			</li>
		</ul>
	</div>


	<!-- Center zone -->
	<div class="body">
		<!-- Map -->
		<svg viewBox="0 0 1881 950" id="svgmap">
			<g
					ng-repeat="terr in game.territories.list"
					fill="{{(terr.id == game.hoveredTerritory.id) ? 'rgba(255,255,255,0.33)' : (terr.id == game.concernedTerritory.id ? '#222222' : terr.color.css())}}"
					ng-mouseenter="game.hoveredTerritory = terr"
					ng-mouseleave="game.hoveredTerritory = undefined"
					stroke="{{terr.id == game.concernedTerritory.id ? 'red' : 'black'}}" stroke-width="{{(terr.id == game.hoveredTerritory.id || terr.id == game.concernedTerritory.id) ? 3 : 1}}" stroke-linecap="round">
				<path ng-repeat="d in terr.path" d="{{d}}" />
			</g>
		</svg>
	</div>


	<!--
	<dl id="plateau">
		<dt ng-repeat="square in board.squares">
			<span class="case">{{$index+1}}</span>
			<span class="joueurs">
				<span class="ideology {{p.ideology.slug}}" ng-repeat="p in square.players" title="{{j.pseudo}}"></span>
			</span>
		</dt>
	</dl>-->
</div>


<?php
pied();
