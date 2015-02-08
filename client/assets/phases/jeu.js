// Jeu phase
var jeuPhase = new Phase('jeu',
    function(scope) {
        $http = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('$http');
        $http.get('data.ajax.php')
            .success(function (result) {
            scope.territoires = result.territory;
            for (var id in scope.territoires)
            {
                // TODO: encapsuler dans une classe Territoire
                var terr = scope.territoires[id];
                terr.proprietaire = null;
                terr.jauges = [];
                var lvl = Math.round(Math.random()*255);
                terr.couleur = 'rgba('+lvl+','+lvl+','+lvl+',0.5)';
                terr.border = 'white';
            }

            // result.gauge

            // result.ideology
        })
        .error(function() {
            console.log('Game\'s data can\'t be reached!');
        });
    },
    function(scope) {
    },
    function(scope) {
    });

jeuPhase.operations.insert('partenaires', function($scope, partenairs) {
    console.log(partenairs);
});

jeuPhase.operations.insert('updates', function($scope, updates) {
    console.log(updates);
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