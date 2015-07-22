// Salons phase
var salonsPhase = new Phase('salons',
    function(scope) {
    },
    function(scope) {
    },
    function(scope) {
    });

salonsPhase.hasPopunder = true;

/**
 * Receiving rooms from server
 * We store them into the scope (ng update the view)
 */
salonsPhase.operations.insert('salons', function($scope, salons) {
    $scope.salons = salons;
});

salonsPhase.operations.insert('joined', function($scope, salon) {
    $scope.salon = salon;
});



salonsPhase.userActions.insert('join', function($scope, index) {
    ws = angular.element(document.querySelector('#IdeologiaCtrl')).injector().get('ws');
    ws.emit('join', index);
});
