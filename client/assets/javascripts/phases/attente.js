// Waiting (attente) phase
var attentePhase = new Phase('attente',
    function(scope, http, ws) {
        console.log("Attente is initialized");
    },
    function(scope, http, ws) {
        console.log("Attente is started");
        scope.popunderTitle = 'Joueurs';
    },
    function() {
        console.log('Ending attente phase');
    });