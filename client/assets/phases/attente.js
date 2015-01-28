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