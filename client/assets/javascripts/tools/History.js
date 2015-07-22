function Msg(content) {

    function addZero(i) {
        if (i < 10) {
            i = "0" + i;
        }
        return i;
    }

    var date = new Date();
    this.time = addZero(date.getHours())+':'+addZero(date.getMinutes())+':'+addZero(date.getSeconds());
    this.content = content;
}

function History(limit) {
    this.limit = limit;
    this.limitReached = false;

    this.data = [];

    this.add = function(msg) {
        this.data.push(new Msg(msg));
        if (this.limitReached)
            this.data.shift();

        if (this.data.length >= this.limit)
            this.limitReached = true;
    }.bind(this);

    this.reset = function() {
        this.limitReached = false;
        this.data = [];
    }.bind(this);
}