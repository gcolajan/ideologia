// Waiting (attente) phase
var attentePhase = new Phase('attente',
    function(scope) {
    },
    function(scope) {
    },
    function(scope) {
    });

attentePhase.hasPopunder = true;

attentePhase.operations.insert('waitingWith', function($scope, adversaires) {
    $scope.adversaires = adversaires;
});

attentePhase.userActions.insert('changeRoom', function($scope, args) {
    ws = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('ws');
    ws.emit('unjoin');
});
