function AutoViewBox(path) {
    this.infX = 0;
    this.infY = 0;
    this.supX = 0;
    this.supY = 0;

    var curX = 0;
    var curY = 0;
    var initialized = false;

    // Works only with "m" paths
    for (var d in path)
    {
        var first = true;
        var tmpPath = path[d].substr(2, path[d].length-4);

        // Splitting on space to have coordinates
        tmpPath = tmpPath.split(" ");

        for (var coord in tmpPath)
        {
            // Splitting on "," to get X & Y
            var c = tmpPath[coord].split(",");

            var x = Number(c[0]);
            var y = Number(c[1]);

            if (!initialized)
            {
                initialized = true;
                this.infX = x;
                this.supX = x;
                this.infY = y;
                this.supY = y;

                first = false;
                curX = x;
                curY = y;
            }
            else
            {
                if (first) {
                    first = false;
                    curX = x;
                    curY = y;
                } else {
                    curX += x;
                    curY += y;
                }

                if (curX < this.infX)
                    this.infX = curX;
                if (curX > this.supX)
                    this.supX = curX;

                if (curY < this.infY)
                    this.infY = curY;
                if (curY > this.supY)
                    this.supY = curY;

            }
        }
    }

    this.get = function(margin) {
        if (typeof margin === 'undefined')
            margin = 0;

        return (this.infX-margin) +
            " " +
            (this.infY-margin) +
            " " +
            ((this.supX-this.infX)+(2*margin)) +
            " " +
            ((this.supY-this.infY)+(2*margin));
    }.bind(this);

}