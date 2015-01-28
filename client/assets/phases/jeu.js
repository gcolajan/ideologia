// Jeu phase
var jeuPhase = new Phase('jeu',
    function(scope) {
        console.log("Jeu is initialized");

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
        console.log("Jeu is started");
    },
    function(scope) {
        console.log('Ending jeu phase');
    });