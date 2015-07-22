var introductionPhase = new Phase('introduction',
    function(scope) {
    },
    function(scope) {
    },
    function(scope) {
    });

introductionPhase.hasPopunder = true;

introductionPhase.userActions.insert('setPseudo', function($scope, args) {
    // Updating the local model
    $scope.pseudo = pseudo.value;

    // Emitting some data to the server
    ws = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('ws');
    ws.emit('pseudo', $scope.pseudo);
});
