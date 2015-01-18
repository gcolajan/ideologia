// Salons phase
var salonsPhase = new Phase('salons',
    function(scope, http, ws) {
        console.log("Salon is initialized");
    },
    function(scope, http, ws) {
        console.log("Salon is started");
        scope.popunderTitle = 'Salons de jeu';
    },
    function() {
        console.log('Ending salon phase');
    });