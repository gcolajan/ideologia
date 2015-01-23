// Salons phase
var salonsPhase = new Phase('salons',
    function(scope) {
        console.log("Salon is initialized");
    },
    function(scope) {
        console.log("Salon is started");
        scope.popunderTitle = 'Salons de jeu';
    },
    function(scope) {
        console.log('Ending salon phase');
    });