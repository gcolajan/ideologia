// Waiting (attente) phase
var attentePhase = new Phase('attente',
    function(scope) {
        console.log("Attente is initialized");
    },
    function(scope) {
        console.log("Attente is started");
        scope.popunderTitle = 'Joueurs';
    },
    function(scope) {
        console.log('Ending attente phase');
    });

attentePhase.hasPopunder = true;