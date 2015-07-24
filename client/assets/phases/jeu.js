// Jeu phase
var jeuPhase = new Phase('jeu',
    function(scope) {
    },
    function(scope) {
    },
    function(scope) {
    });

jeuPhase.operations.insert('partenaires', function($scope, partners) {
    for (var p in partners)
    {
        var partner = partners[p];
        var ideology = $scope.game.ideologies.get(partner['ideologie']);
        $scope.game.players.push(new Player(partner['pseudo'], ideology));

        if (partner['pseudo'] == $scope.pseudo)
            $scope.game.me = p;
    }
});

jeuPhase.operations.insert('joueurCourant', function($scope, currentPlayer) {
    $scope.game.currentPlayer = currentPlayer;

    // Mode Quick-DEBUG
    if ($scope.game.me == currentPlayer)
    {
        ws = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('ws');
        ws.emit('des');
    }
});

jeuPhase.operations.insert('playersData', function($scope, data) {
    // When we receive an update about player's data, if we haven't chosen our operation, it's too late...
    $scope.game.choseOperation = false;
    // The choice/simulation is over
    $scope.game.selectedOperation = undefined;
    $scope.game.currentSimulation = undefined;

    for (var i = 0 ; i < data.length ; ++i)
    {
        var player = $scope.game.players[i];
        for (var id in data[i])
        {
            var territory = $scope.game.territories.get(id, "id");
            // If the territory has changed of owner
            if (!player.territories.exists(id))
            {
                // We look on ours player, which one has this territory
                for (var p in $scope.game.players)
                {
                    var curPlayer = $scope.game.players[p];
                    if (curPlayer.territories.exists(id))
                    {
                        curPlayer.losingTerritory(id);
                        break;
                    }
                }

                // We give the territory to that player
                player.addTerritory(territory)
                $scope.game.history.add(territory.name+' : '+curPlayer.getColoured()+" => "+player.getColoured());
            }

            // Updating health of the territory
            territory.updateState(data[i][id]);
        }
    }
});

jeuPhase.operations.insert('evenement', function($scope, event) {
    //console.log("Event has been encountered: "+event);
});

jeuPhase.operations.insert('des', function($scope, des) {
    //console.log("Des: "+des);
});

jeuPhase.operations.insert('jcPosition', function($scope, pos) {
    // We put the current player on the right square
    $scope.game.getCurrentPlayer().position = pos;

    var terr = $scope.game.territoryAt(pos);
    if (terr !== null)
    {
        $scope.game.lastConcernedTerritory = terr;

        if ($scope.game.amICurrent())
            $scope.game.currentPlayDescription = "<strong>Vous</strong> êtes sur ";
        else
            $scope.game.currentPlayDescription = $scope.game.getCurrentPlayer().getColoured()+" est sur ";

        var currentOwner = $scope.game.getOwnerOf(terr);
        if ($scope.game.getMe() == currentOwner)
            $scope.game.currentPlayDescription += "<em>votre</em> territoire";
        else if ($scope.game.getCurrentPlayer() == currentOwner)
            $scope.game.currentPlayDescription += "son propre territoire";
        else
            $scope.game.currentPlayDescription += "le territoire de "+currentOwner.getColoured();

        $scope.game.currentPlayDescription += '.';
    }
    else
    {
        if ($scope.game.amICurrent())
            $scope.game.currentPlayDescription = "Vous êtes";
        else
            $scope.game.currentPlayDescription = $scope.game.getCurrentPlayer().getColoured()+" est";

        $scope.game.currentPlayDescription += " sur une case à action spécifique.";
    }

    // Returns the territory on which is the current player
    $scope.game.concernedTerritory = terr;
});

jeuPhase.operations.insert('gain', function($scope, gain) {
    //console.log("Current money: "+gain);
});

jeuPhase.operations.insert('operations', function($scope, operations) {
    // Mode Quick-DEBUG
    //ws = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('ws');
    //ws.emit('operation', operations[0]);

    $scope.game.makeUserChose(operations);
});

jeuPhase.operations.insert('appliedOperation', function($scope, operationId) {
    $scope.game.history.add(
        '<span style="color:'+$scope.game.getOwnerOf($scope.game.concernedTerritory).ideology.color.css()+';">'+$scope.game.concernedTerritory.name+'</span> :' +
        ' «&nbsp;'+$scope.game.operations.get(operationId, 'id').name+'&nbsp;» '+
        $scope.game.getCurrentPlayer().getIconified()
    );
});

jeuPhase.operations.insert('score', function($scope, score) {
    console.log(score);
});

jeuPhase.userActions.insert('sendOperation', function($scope, operationId) {
    // Emitting some data to the server
    ws = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('ws');
    ws.emit('operation', operationId);

    // Operation has been chosen, we close the popup
    $scope.game.choseOperation = false;
});
