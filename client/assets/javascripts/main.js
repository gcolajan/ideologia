var app = angular.module('myGame', []);

app.controller('IdeologiaCtrl', function($scope, ws) {

	$scope.popunderTitle = '';

	$scope.currentPhase = undefined;

	$scope.salons = [];
	$scope.adversaires = [];

	// Définition des actions associées à chaque phase
	$scope.phases = {
		introduction: function() {
			$scope.popunderTitle = 'Connexion';
		},
		salons: function() {
			$scope.popunderTitle = 'Salons de jeu';
		},
		attente: function() {
			$scope.popunderTitle = 'Joueurs';
		}
	};

	ws.on('phase', function(phase) {
		if ($scope.phases[phase] !== undefined) {
			$scope.currentPhase = phase;
			$scope.phases[phase]();
		} else
			console.log('Phase unknown');
	});

	ws.on('salons', function(salons) {
		$scope.salons = salons;
		console.log(salons);
	});

	ws.on('joined', function(salon) {
		$scope.salon = salon;
		$scope.currentPhase = 'attente';
	});

	ws.on('waitingWith', function(adversaires) {
		$scope.adversaires = adversaires;
	})

	$scope.showPopunder = function() {
		return $scope.currentPhase == 'introduction'
			|| $scope.currentPhase == 'salons'
			|| $scope.currentPhase == 'attente';
	}

	$scope.sendPseudo = function() {
		ws.emit('pseudo', $scope.pseudo);
		console.log("pseudo send");
	}

	$scope.joinSalon = function(index) {
		ws.emit('join', index);
		console.log('salon send');
	}
});

app.controller('MapCtrl', function($scope, ws) {

});

app.controller('MovementCtrl', function($scope, ws) {

});
