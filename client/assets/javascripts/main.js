"use strict";

var app = angular.module('myGame', []);

app.controller('IdeologiaCtrl', function($scope, $http, ws) {

	$scope.game = 'Ideologia';

	$scope.popunderTitle = '';

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

	ws.on('phase', function(phase) {
		// If they were a previous phase, we end it before
		if ($scope.currentPhase !== undefined) {
			$scope.currentPhase.end($scope, $http, ws);
		}

		// We're looking for the phase asked by the server
		var hasRegistered = false;
		for (var i in $scope.phases) {
			if ($scope.phases[i].name == phase) {
				$scope.currentPhase = $scope.phases[i];
				hasRegistered = true;

				$scope.currentPhase.init($scope, $http, ws);
				ws.registerPhase($scope.currentPhase);
				$scope.currentPhase.start($scope, $http, ws);
			}
		}

		if (!hasRegistered)
			console.log('Server asked for phase '+phase+' but isn\'t registered.')
	});

	ws.on('salons', function(salons) {
		$scope.salons = salons;
		console.log(salons);
	});

	ws.on('joined', function(salon) {
		$scope.salon = salon;
		//$scope.currentPhase.name = 'attente';
	});

	ws.on('waitingWith', function(adversaires) {
		$scope.adversaires = adversaires;
	});

	$scope.showPopunder = function() {
		return $scope.currentPhase !== undefined && (
			$scope.currentPhase.is('introduction')
			|| $scope.currentPhase.is('salons')
			|| $scope.currentPhase.is('attente'));
	};

	$scope.sendPseudo = function() {
		ws.emit('pseudo', $scope.pseudo);
		console.log("pseudo send");
	};

	$scope.joinSalon = function(index) {
		ws.emit('join', index);
		console.log('salon send');
	};



	$scope.onTerritoire = function(territoire) {
		$scope.currentTerr = territoire;
		$scope.oldColor = $scope.currentTerr.couleur;
		$scope.currentTerr.couleur = 'rgba(100,30,168,0.6)';

	};

	$scope.leaveTerritoire = function() {
		$scope.currentTerr.couleur = $scope.oldColor;
		$scope.currentTerr = null;
	}
});

app.controller('MapCtrl', function($scope, ws) {

});

app.controller('MovementCtrl', function($scope, ws) {

});
