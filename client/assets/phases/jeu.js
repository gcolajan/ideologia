// Jeu phase
var jeuPhase = new Phase('jeu',
    function(scope) {
        scope.game = new Game();
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

jeuPhase.operations.insert('updates', function($scope, updates) {
    for (var i = 0 ; i < updates['playersData'].length ; ++i)
    {
        var player = $scope.game.players[i];
        player.position = updates['playersData'][i]['position'];
        for (var id in updates['playersData'][i]['territories'])
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
            }

            // Updating health of the territory
            territory.updateState(updates['playersData'][i]['territories'][id]);
        }
    }
    /*
    playersData
    pcases
    fonds
    jauges*/
});

jeuPhase.operations.insert('evenement', function($scope, event) {
    //console.log("Event has been encountered: "+event);
});

jeuPhase.operations.insert('des', function($scope, des) {
    //console.log("Des: "+des);
});

jeuPhase.operations.insert('position', function($scope, pos) {
    $scope.game.getMe().position = pos;
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