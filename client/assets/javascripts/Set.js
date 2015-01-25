function Set() {
    this.array = {};
}

Set.prototype.exists = function(key) {
    return (this.array[key] !== undefined);
};

Set.prototype.insert = function(key, value) {
    if (this.exists(key)) {
        console.log("Set::insert: "+key+" already exists.");
        return false;
    }

    if (value === undefined) {
        console.log("Set::insert: value is undefined for "+key+".");
        return false;
    }

    this.array[key] = value;
    return true;
};

Set.prototype.get = function(key) {
    if (!this.exists(key)) {
        console.log("Set::get: "+key+" doesn\'t exists.");
    }

    return this.array[key];
};

Set.prototype.unset = function(key) {
    if (this.exists(key))
        this.array[key] = undefined;
};

Set.prototype.toJSON = function() {
    return this.array;
};