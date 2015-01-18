// Jeu phase
var jeuPhase = new Phase('jeu',
    function(scope, http, ws) {
        console.log("Attente is initialized");
        http({
            method: 'GET',
            url: 'data.ajax.php'
        }).success(function (result) {
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
        });
    },
    function(scope, http, ws) {
        console.log("Attente is started");
    },
    function(scope, http, ws) {
        console.log('Ending attente phase');
    });