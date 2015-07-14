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
        var tmpPath = path[d].substr(2);

        // Splitting on space to have coordinates
        tmpPath = tmpPath.split(" ");

        for (var coord in tmpPath)
        {
            // Splitting on "," to get X & Y
            var c = tmpPath[coord].split(",");

            if (!initialized)
            {
                initialized = true;
                this.infX = c[0];
                this.supX = c[0];
                this.infY = c[1];
                this.supY = c[1];

                first = false;
                curX = c[0];
                curY = c[1];
            }
            else
            {
                if (first) {
                    first = false;
                    curX = c[0];
                    curY = c[1];
                } else {
                    curX += c[0];
                    curY += c[1];
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

    this.get = function() {
        return this.infX+" "+this.infY+" " +this.supX+" "+this.supY;
    }.bind(this);

}