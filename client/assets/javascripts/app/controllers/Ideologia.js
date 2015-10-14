app.controller('IdeologiaCtrl', function($scope, $http, $interval, ws) {

    $scope.pseudo = undefined;

    $scope.gameName = "Ideologia";
    $scope.game = new Game();

    $scope.currentPhase = undefined;

    $scope.salons = [];
    $scope.adversaires = [];
    $scope.ideologies = [];

    $scope.operationTimer = 0;
    $scope.timeLeft = 300;
    $scope.formattedOperationTimer = "--";
    $scope.formattedTimeLeft = "--:--";

    $scope.wsInfo = true;
    $scope.wsMsg = "Ouverture de la connexion en cours...";

    /***********************/

    // Définition des actions associées à chaque phase
    $scope.phases = [];
    $scope.phases.push(introductionPhase);
    $scope.phases.push(salonsPhase);
    $scope.phases.push(attentePhase);
    $scope.phases.push(jeuPhase);

    /**
     * Permit to call the right operation when we receive a message (which is not globally referenced)
     * @param msgName
     * @param args
     */
    ws.setOnMessageCallback(function(msgName, args) {
        if ($scope.currentPhase === undefined) {
            console.log('IdeologiaCtrl::onMessageCallback: action can\'t be performed (no phase).');
            return;
        }

        if (!$scope.currentPhase.operations.exists(msgName)) {
            console.log('IdeologiaCtrl::onMessageCallback: "'+msgName+'" isn\'t referenced (phase: '+$scope.currentPhase.name+').');
            return;
        }

        // Triggering the user action with the current scope and provided args
        $scope.currentPhase.getOperation(msgName)($scope, args);
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

    /**
     * How do we react when we receive the instruction to switch phase
     */
    ws.on('phase', function(phase) {
        // If they were a previous phase, we end it before
        if ($scope.currentPhase !== undefined) {
            $scope.currentPhase.end($scope);
        }

        // We're looking for the phase asked by the server
        var found = false;
        for (var i in $scope.phases) {
            if ($scope.phases[i].name == phase) {
                $scope.currentPhase = $scope.phases[i];
                found = true;

                $scope.currentPhase.init($scope);

                ws.emit('phaseack', phase);

                $scope.currentPhase.start($scope);
            }
        }

        if (!found)
            console.log('Server asked for phase '+phase+' but isn\'t registered.');
    });

    $scope.setWsMsg = function(msg, err) {
        $scope.wsInfo = typeof err !== 'undefined' ? err : true;
        $scope.wsMsg = msg;
        $scope.$apply();
    };

    ws.setOnConnexionOpened(function() {
        $scope.setWsMsg("Connexion établie !", false);
    });

    ws.setOnInterruptedSocket(function() {
        $scope.setWsMsg("La connexion a été interrompue.");
    });

    ws.setOnUnreachableServer(function() {
        $scope.setWsMsg("Le serveur est inaccessible !");
    });

    ws.setOnClose(function() {
        // Retry?
    });

    // Opening the connection with the host
    ws.open(window.location.hostname, 8080);


    $scope.showPopunder = function() {
        return $scope.currentPhase !== undefined && $scope.currentPhase.hasPopunder;
    };

    var doubleCar = function(value) {
        return (value < 10) ? "0"+value : value;
    };

    $scope.readableTime = function(secs) {
        var minutes = Math.floor(secs/60);
        var seconds = secs - (minutes*60);
        return doubleCar(minutes)+":"+doubleCar(seconds);
    };

    $scope.startOperationTimer = function() {
        $scope.operationTimer = 30;
    }

    var stop;
    $scope.startCounters = function() {
        // Don't start a new one if already one is running
        if ( angular.isDefined(stop) ) return;

        stop = $interval(function() {
            if ($scope.operationTimer > 0)
            {
                $scope.operationTimer -= 1;
                $scope.formattedOperationTimer = doubleCar($scope.operationTimer);
            }

            if ($scope.timeLeft > 0)
                $scope.timeLeft -= 1;
            else
                $scope.stopTimers();

            $scope.formattedTimeLeft = $scope.readableTime($scope.timeLeft);
        }, 1000);
    };

    $scope.stopTimers = function() {
        if (angular.isDefined(stop)) {
            $interval.cancel(stop);
            stop = undefined;
        }
    };

    $scope.$on('$destroy', function() {
        // Make sure that the interval is destroyed too
        $scope.stopTimers();
    });
});
