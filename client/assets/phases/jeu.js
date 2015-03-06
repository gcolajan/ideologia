// Jeu phase
var jeuPhase = new Phase('jeu',
    function(scope) {
        scope.game = new Game();

        $http = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('$http');
        $http.get('data.ajax.php')
            .success(function (result) {
                // Adding territories
                for (var id in  result['territory']) {
                    var territory = result['territory'][id];
                    scope.game.territories.push(new Territory(
                        id,
                        territory['nom'],
                        territory['position'],
                        territory['path']));
                }

                // Adding gauges
                for (var id in result['gauge']) {
                    var gauge = result['gauge'][id];
                    scope.game.gauges.insert(id, new Gauge(gauge['name'], gauge['slug']));
                }

                // Adding ideologies
                for (var id in result['ideology']) {
                    var ideology = result['ideology'][id];
                    scope.game.ideologies.insert(
                        id,
                        new Ideology(
                            ideology['nom'],
                            ideology['slug'],
                            ideology['joueur'],
                            ideology['couleur'],
                            scope.game.gauges,
                            ideology['jauges']
                        )
                    );
                }
            })
            .error(function() {
                console.log('Game\'s data can\'t be reached!');
            });
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
    console.log("Current player is "+currentPlayer);
});

jeuPhase.operations.insert('updates', function($scope, updates) {
    for (var i = 0 ; i < updates['playersData'].length ; ++i)
    {
        var player = $scope.game.players[i];
        player.position = updates['playersData'][i]['position'];
        for (var id in updates['playersData'][i]['territories'])
        {
            var territory = $scope.game.territories.get(id, "id");

            // Updating health of the territory
            territory.setHealth(updates['playersData'][i]['territories'][id]);

            // If the territory has changed of owner
            if (!player.territories.exists(id))
            {
                // We look on ours player, which one has this territory
                for (var p in $scope.game.players)
                {
                    var curPlayer = $scope.game.players[p];
                    if (curPlayer.territories.exists(id))
                    {
                        // We delete it from his list
                        curPlayer.territories.unset(id);
                        break;
                    }
                }

                // We give the territory to that player
                player.territories.insert(id, territory);
            }
        }
    }

    /*
    playersData
    pcases
    fonds
    jauges*/

    console.log("To process: "+updates);
});

jeuPhase.userActions.insert('onTerritory', function($scope, territory) {
    $scope.currentTerr = territory;
    $scope.oldColor = $scope.currentTerr.couleur;
    $scope.currentTerr.couleur = 'rgba(100,30,168,0.6)';
});

jeuPhase.userActions.insert('leaveTerritory', function($scope, _) {
    $scope.currentTerr.couleur = $scope.oldColor;
    $scope.currentTerr = null;
});