var introductionPhase = new Phase('introduction',
    function(scope) {
        console.log("Intro is initialized");
        scope.board = new Board();
        scope.board.init();
    },
    function(scope) {
        console.log("Intro is started");
        scope.popunderTitle = 'Connexion';
    },
    function(scope) {
        console.log('Ending intro phase');
    });