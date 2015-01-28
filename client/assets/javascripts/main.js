"use strict";
var app = angular.module('myGame', []);

app.controller('IdeologiaCtrl', function($scope, $http, ws) {

	$scope.game = 'Ideologia';

	$scope.currentPhase = undefined;
	$scope.currentTerr = null;

	$scope.board = undefined;

	$scope.salons = [];
	$scope.adversaires = [];
	$scope.territoires = [];
	$scope.ideologies = [];


	/***********************/

	// Définition des actions associées à chaque phase
	$scope.phases = [];
	$scope.phases.push(introductionPhase);
	$scope.phases.push(salonsPhase);
	$scope.phases.push(attentePhase);
	$scope.phases.push(jeuPhase);

	/**
	 * How do we react when we receive the instruction to switch phase
	 */
	ws.on('phase', function(phase) {
		// If they were a previous phase, we end it before
		if ($scope.currentPhase !== undefined) {
			$scope.currentPhase.end($scope);
		}

		// We're looking for the phase asked by the server
		var hasRegistered = false;
		for (var i in $scope.phases) {
			if ($scope.phases[i].name == phase) {
				$scope.currentPhase = $scope.phases[i];
				hasRegistered = true;

				$scope.currentPhase.init($scope);
				ws.registerPhase($scope.currentPhase);
				$scope.currentPhase.start($scope);
				console.log($scope.currentPhase.name+' phase is started.');
			}
		}

		if (!hasRegistered)
			console.log('Server asked for phase '+phase+' but isn\'t registered.');
	});


	/**
	 * Permit to trigger "userActions" from the current phase
	 * @param actionName
	 * @param args
	 */
	$scope.trigger = function(actionName, args) {
		if ($scope.currentPhase === undefined) {
			console.log('IdeologiaCtrl::trigger: action can\'t be performed (no phase).');
			return;
		}

		if (!$scope.currentPhase.userActions.exists(actionName)) {
			console.log('IdeologiaCtrl::trigger: "'+actionName+'" isn\'t referenced (phase: '+$scope.currentPhase.name+').');
			return;
		}

		// Triggering the user action with the current scope and provided args
		$scope.currentPhase.getUserAction(actionName)($scope, args);
	};


	$scope.showPopunder = function() {
		return $scope.currentPhase !== undefined && $scope.currentPhase.hasPopunder;
	};

});
