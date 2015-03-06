// Stockage d'une couleur
function Color(rgba, ga, blue, alpha) {
    this.red = 0;
    this.green = 0;
    this.blue = 0;
    this.alpha = 1.0;

    // Defined with 2 args
    if (ga != undefined && blue == undefined)
    {
        this.alpha = ga;
        if (rgba.length === undefined) {
            this.red = rgba;
            this.green = rgba;
            this.blue = rgba;
        } else {
            this.red = rgba[0];
            this.green = rgba[1];
            this.blue = rgba[2];
        }
    }
    else if (ga == undefined && blue == undefined) { // Defined with 1 arg
        // If that arg isn't an array, silver color
        if (rgba.length === undefined) {
            this.red = rgba;
            this.green = rgba;
            this.blue = rgba;
            this.alpha = 0.1;
        } else {
            this.red = rgba[0];
            this.green = rgba[1];
            this.blue = rgba[2];
            this.alpha = (rgba.length < 3) ? 1.0 : rgba[3];
        }
    } else {
        this.red = rgba;
        this.green = ga;
        this.blue = blue;
        this.alpha = (alpha == undefined) ? 1.0 : alpha;
    }

    this.css = function() {
        return "rgba("+this.red+", "+this.green+", "+this.blue+", "+this.alpha+")";
    }.bind(this);
}
