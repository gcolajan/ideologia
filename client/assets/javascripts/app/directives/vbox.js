/**
 * Trick for lower-case on "viewBox" with combined behavior of Angular&jQuery
 */
app.directive('vbox', function() {
    return {
        link: function(scope, element, attrs) {
            attrs.$observe('vbox', function(value) {
                if (typeof value === "undefined" || value === "")
                    value = "0 0 0 0";
                element.get(0).setAttribute("viewBox", value);
            })
        }
    };
});