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
    this.shown = undefined;

    this.data = [];
    this.defaultMsg = new Msg("-");

    this.getLastOne = function() {
        return Math.min(this.limit, this.data.length) - 1;
    }.bind(this);

    this.add = function(msg) {
        this.data.push(new Msg(msg));
        if (this.limitReached)
            this.data.shift();

        var justReached = false;
        if (!this.limitReached && this.data.length >= this.limit)
        {
            justReached = true;
            this.limitReached = true;
        }


        // First message added
        if (typeof this.shown == 'undefined')
            this.shown = 0;

        // Offset of the last message added
        var lastOne = this.getLastOne();


        if (this.shown == 0 // If the oldest was watched, we show the most recent
            || (this.limitReached && this.shown == lastOne) // Or just if we were on the last one (and history full)
            || (this.shown == lastOne-1 && (!this.limitReached || justReached))) // Same but history was not full
            this.shown = lastOne;

        // Otherwise, we keep the "focus" on the current
        if (this.limitReached && this.shown > 0 && this.shown != lastOne)
            this.goPrev();

    }.bind(this);

    this.addTriggeredEvent = function(player, event, concernedPeople) {
        var phrase = player.getColoured()+'<br />déclenche l\'évenement<br />«&nbsp;'+event.name+'&nbsp;»<br />';

        switch (concernedPeople) {
            case -1:
                phrase += 'sur tout ses adveraires';
                break;
            case 0:
                phrase += 'sur lui-même';
                break;
            case 1:
                phrase += 'sur le monde entier';
                break;
        }

        this.add(phrase);
    }.bind(this);


    /**
     * playerSrc: player at the origin of the operation
     * playerDest: player who receive the operation (can be the same)
     * operation: the operation processed
     * territory: the territory concerned by the operation
     * stability: -1 decrease, 0 stable, 1 increase
     * hasChangedOwner: boolean, determine if the territory has changed the owner for playerSrc after the operation
     * @type {function(this:History)}
     */
    this.addOperation = function(playerSrc, playerDest, operation, territory, stability, hasChangedOwner) {

        var phrase = playerSrc.getColoured()+' déclenche<br />«&nbsp;'+operation.name+'&nbsp;»<br />sur <em>'+territory.name+'</em> ('+playerDest.getColoured()+').<br />';

        if (hasChangedOwner && playerSrc != playerDest)
            phrase += '<strong>Le territoire bascule.</strong>';
        else
            if (stability < 0)
                phrase += 'Le territoire perd en stabilité...';
            else if (stability > 0)
                phrase += 'Le territoire se stabilise !';
            else
                phrase += 'Aucun effet n\'est véritablement ressenti.';

        this.add(phrase);
    }.bind(this);

    this.reset = function() {
        this.limitReached = false;
        this.data = [];
        this.shown = undefined;
    }.bind(this);

    this.getCurrent = function() {
        if (typeof this.shown == 'undefined')
            return this.defaultMsg;

        if (this.shown < 0 || this.shown > this.getLastOne())
            return this.defaultMsg;

        return this.data[this.shown];
    }.bind(this);

    this.canGoNext = function() {
        return !(this.shown >= this.getLastOne()) && this.data.length != 0;
    }.bind(this);

    this.canGoPrev = function() {
        return !(this.shown <= 0) && this.data.length != 0;
    }.bind(this);

    this.goNext = function() {
        if (!this.canGoNext())
            return;

        this.shown += 1;
    }.bind(this);

    this.goPrev = function() {
        if (!this.canGoPrev())
            return;

        this.shown -= 1;
    }.bind(this);
}