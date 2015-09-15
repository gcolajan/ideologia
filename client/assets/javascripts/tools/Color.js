// Stockage d'une couleur
function Color(rgba, ga, blue, alpha) {
    this.red = 0;
    this.green = 0;
    this.blue = 0;
    this.alpha = 1.0;

    // Defined with 2 args
    if (rgba != undefined && ga != undefined && blue == undefined)
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
    else if (rgba != undefined && ga == undefined && blue == undefined) { // Defined with 1 arg
        // If that arg isn't an array, silver color
        if (rgba.length === undefined) {
            this.red = rgba;
            this.green = rgba;
            this.blue = rgba;
        } else {
            this.red = rgba[0];
            this.green = rgba[1];
            this.blue = rgba[2];
            this.alpha = (rgba.length < 4) ? 1.0 : rgba[3];
        }
    }
    else if (rgba == undefined) { // Not defined
        // That's ok
    } else { // Fully defined
        this.red = rgba;
        this.green = ga;
        this.blue = blue;
        this.alpha = (alpha == undefined) ? 1.0 : alpha;
    }

    this.css = function() {
        return "rgba("+this.red+", "+this.green+", "+this.blue+", "+this.alpha+")";
    }.bind(this);

    this.clone = function() {
        return new Color(this.red, this.green, this.blue, this.alpha);
    }.bind(this);

    this.hueVariation = function() {
        var HSL = rgbToHsl(this.red, this.green, this.blue)

        var variationMaxH = 0.12;
        var variationH = Math.random()*variationMaxH-(variationMaxH/2);

        var H = HSL[0]+variationH;
        H = (H > 1) ? 1-H : 1+H;

        // Variation aléatoire de la saturation
        var portionValide = 0.33; // petit = saturé
        var S = Math.random()*portionValide+(1-portionValide);

        // Variation relative de l'intensité lumineuse
        var RGB = hslToRgb(H, S, HSL[2]);

        this.red = Math.floor(RGB[0]);
        this.green = Math.floor(RGB[1]);
        this.blue = Math.floor(RGB[2]);
    }.bind(this);
}
