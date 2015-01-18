var introductionPhase = new Phase('introduction',
    function(scope, http, ws) {
        console.log("Intro is initialized");
        scope.board = new Board();
        scope.board.init();
    },
    function(scope, http, ws) {
        console.log("Intro is started");
        scope.popunderTitle = 'Connexion';
    },
    function(scope, http, ws) {
        console.log('Ending intro phase');
    });