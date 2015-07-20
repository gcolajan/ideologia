/**
 * Trick for lower-case on "viewBox" with combined behavior of Angular&jQuery
 */
app.directive('vbox', function() {
    return {
        link: function(scope, element, attrs) {
            attrs.$observe('vbox', function(value) {
                element.get(0).setAttribute("viewBox", value);
            })
        }
    };
});